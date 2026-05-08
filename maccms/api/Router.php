<?php
class Router {
    private $db;
    private $routes = [];

    public function __construct($db) {
        $this->db = $db;
        $this->registerRoutes();
    }

    private function registerRoutes() {
        $this->routes = [
            'GET /api/admin/login' => 'handleAdminLogin',
            'POST /api/admin/login' => 'handleAdminLogin',
            'GET /api/admin/info' => 'handleAdminInfo',
            'GET /api/videos' => 'handleGetVideos',
            'GET /api/videos/:id' => 'handleGetVideo',
            'POST /api/videos' => 'handleCreateVideo',
            'PUT /api/videos/:id' => 'handleUpdateVideo',
            'DELETE /api/videos/:id' => 'handleDeleteVideo',
            'GET /api/categories' => 'handleGetCategories',
            'POST /api/categories' => 'handleCreateCategory',
            'PUT /api/categories/:id' => 'handleUpdateCategory',
            'DELETE /api/categories/:id' => 'handleDeleteCategory',
            'GET /api/stats' => 'handleGetStats',
        ];
    }

    public function dispatch($method, $path) {
        $routeKey = "{$method} {$path}";
        
        foreach ($this->routes as $route => $handler) {
            $pattern = preg_replace('/:\w+/', '([^/]+)', $route);
            $pattern = '#^' . $pattern . '$#';
            
            if (preg_match($pattern, $routeKey, $matches)) {
                array_shift($matches);
                return $this->$handler(...$matches);
            }
        }
        
        Response::error('路由不存在', 404);
    }

    private function handleAdminLogin() {
        if ($_SERVER['REQUEST_METHOD'] === 'GET') {
            Response::success(['message' => '请使用 POST 方法登录']);
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $username = $input['username'] ?? '';
        $password = $input['password'] ?? '';

        if (empty($username) || empty($password)) {
            Response::error('用户名和密码不能为空', 400);
        }

        $admin = $this->db->fetchOne(
            "SELECT * FROM {prefix}admin WHERE admin_name = ? AND admin_status = 1",
            [$username]
        );

        if (!$admin || !password_verify($password, $admin['admin_pwd'])) {
            Response::error('用户名或密码错误', 401);
        }

        $token = bin2hex(random_bytes(32));
        $this->db->update('admin', [
            'admin_login_time' => time(),
            'admin_login_num' => $admin['admin_login_num'] + 1
        ], 'admin_id = ?', [$admin['admin_id']]);

        Response::success([
            'token' => $token,
            'userInfo' => [
                'id' => $admin['admin_id'],
                'username' => $admin['admin_name'],
                'role' => $admin['group_id']
            ]
        ], '登录成功');
    }

    private function handleAdminInfo() {
        $token = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        
        if (empty($token)) {
            Response::error('未授权', 401);
        }

        Response::success([
            'id' => 1,
            'username' => 'admin',
            'role' => 1,
            'permissions' => ['*']
        ]);
    }

    private function handleGetVideos() {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $pageSize = isset($_GET['pageSize']) ? (int)$_GET['pageSize'] : 20;
        $keyword = $_GET['keyword'] ?? '';
        $typeId = $_GET['type_id'] ?? '';

        $where = '1=1';
        $params = [];

        if (!empty($keyword)) {
            $where .= ' AND vod_name LIKE ?';
            $params[] = "%{$keyword}%";
        }

        if (!empty($typeId)) {
            $where .= ' AND type_id = ?';
            $params[] = $typeId;
        }

        $offset = ($page - 1) * $pageSize;
        
        $total = $this->db->fetchOne(
            "SELECT COUNT(*) as count FROM {prefix}vod WHERE {$where}",
            $params
        )['count'];

        $list = $this->db->fetchAll(
            "SELECT * FROM {prefix}vod WHERE {$where} ORDER BY vod_id DESC LIMIT {$offset}, {$pageSize}",
            $params
        );

        Response::paginate($list, $total, $page, $pageSize);
    }

    private function handleGetVideo($id) {
        $video = $this->db->fetchOne(
            "SELECT * FROM {prefix}vod WHERE vod_id = ?",
            [$id]
        );

        if (!$video) {
            Response::error('视频不存在', 404);
        }

        Response::success($video);
    }

    private function handleCreateVideo() {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $data = [
            'type_id' => $input['type_id'] ?? 1,
            'vod_name' => $input['vod_name'] ?? '',
            'vod_sub' => $input['vod_sub'] ?? '',
            'vod_en' => $input['vod_en'] ?? '',
            'vod_pic' => $input['vod_pic'] ?? '',
            'vod_content' => $input['vod_content'] ?? '',
            'vod_play_url' => $input['vod_play_url'] ?? '',
            'vod_time' => time(),
            'vod_time_add' => time(),
        ];

        $id = $this->db->insert('vod', $data);
        Response::success(['id' => $id], '创建成功', 201);
    }

    private function handleUpdateVideo($id) {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $data = [];
        $allowedFields = ['type_id', 'vod_name', 'vod_sub', 'vod_en', 'vod_pic', 'vod_content', 'vod_play_url'];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $data[$field] = $input[$field];
            }
        }

        if (empty($data)) {
            Response::error('没有可更新的字段', 400);
        }

        $data['vod_time'] = time();
        $this->db->update('vod', $data, 'vod_id = ?', [$id]);
        
        Response::success(null, '更新成功');
    }

    private function handleDeleteVideo($id) {
        $this->db->delete('vod', 'vod_id = ?', [$id]);
        Response::success(null, '删除成功');
    }

    private function handleGetCategories() {
        $list = $this->db->fetchAll("SELECT * FROM {prefix}type ORDER BY type_sort ASC, type_id ASC");
        Response::success($list);
    }

    private function handleCreateCategory() {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $data = [
            'type_name' => $input['type_name'] ?? '',
            'type_en' => $input['type_en'] ?? '',
            'type_sort' => $input['type_sort'] ?? 0,
            'type_pid' => $input['type_pid'] ?? 0,
        ];

        $id = $this->db->insert('type', $data);
        Response::success(['id' => $id], '创建成功', 201);
    }

    private function handleUpdateCategory($id) {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $data = [];
        $allowedFields = ['type_name', 'type_en', 'type_sort', 'type_pid'];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $data[$field] = $input[$field];
            }
        }

        if (empty($data)) {
            Response::error('没有可更新的字段', 400);
        }

        $this->db->update('type', $data, 'type_id = ?', [$id]);
        Response::success(null, '更新成功');
    }

    private function handleDeleteCategory($id) {
        $this->db->delete('type', 'type_id = ?', [$id]);
        Response::success(null, '删除成功');
    }

    private function handleGetStats() {
        $vodCount = $this->db->fetchOne("SELECT COUNT(*) as count FROM {prefix}vod")['count'];
        $typeCount = $this->db->fetchOne("SELECT COUNT(*) as count FROM {prefix}type")['count'];
        $todayVod = $this->db->fetchOne(
            "SELECT COUNT(*) as count FROM {prefix}vod WHERE vod_time_add >= ?",
            [strtotime('today')]
        )['count'];

        Response::success([
            'totalVideos' => (int)$vodCount,
            'totalCategories' => (int)$typeCount,
            'todayVideos' => (int)$todayVod,
            'totalViews' => 0
        ]);
    }
}
