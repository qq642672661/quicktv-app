<?php
class Response {
    public static function success($data = null, $message = 'success', $code = 200) {
        http_response_code($code);
        echo json_encode([
            'code' => 0,
            'message' => $message,
            'data' => $data,
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error($message = 'error', $code = 400, $data = null) {
        http_response_code($code);
        echo json_encode([
            'code' => -1,
            'message' => $message,
            'data' => $data,
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function paginate($list, $total, $page, $pageSize) {
        self::success([
            'list' => $list,
            'total' => (int)$total,
            'page' => (int)$page,
            'pageSize' => (int)$pageSize,
            'totalPages' => ceil($total / $pageSize)
        ]);
    }
}
