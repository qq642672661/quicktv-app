<?php
class Database {
    private $pdo;
    private $prefix;

    public function __construct($config) {
        $dsn = "{$config['type']}:host={$config['hostname']};port={$config['hostport']};dbname={$config['database']};charset={$config['charset']}";
        
        try {
            $this->pdo = new PDO($dsn, $config['username'], $config['password'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
            $this->prefix = $config['prefix'];
        } catch (PDOException $e) {
            throw new Exception('数据库连接失败: ' . $e->getMessage());
        }
    }

    public function query($sql, $params = []) {
        $sql = str_replace('{prefix}', $this->prefix, $sql);
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public function fetchAll($sql, $params = []) {
        return $this->query($sql, $params)->fetchAll();
    }

    public function fetchOne($sql, $params = []) {
        return $this->query($sql, $params)->fetch();
    }

    public function insert($table, $data) {
        $table = $this->prefix . $table;
        $fields = array_keys($data);
        $placeholders = array_fill(0, count($fields), '?');
        
        $sql = "INSERT INTO {$table} (" . implode(', ', $fields) . ") VALUES (" . implode(', ', $placeholders) . ")";
        $this->query($sql, array_values($data));
        
        return $this->pdo->lastInsertId();
    }

    public function update($table, $data, $where, $whereParams = []) {
        $table = $this->prefix . $table;
        $sets = [];
        $values = [];
        
        foreach ($data as $key => $value) {
            $sets[] = "{$key} = ?";
            $values[] = $value;
        }
        
        $sql = "UPDATE {$table} SET " . implode(', ', $sets) . " WHERE {$where}";
        $this->query($sql, array_merge($values, $whereParams));
        
        return true;
    }

    public function delete($table, $where, $params = []) {
        $table = $this->prefix . $table;
        $sql = "DELETE FROM {$table} WHERE {$where}";
        $this->query($sql, $params);
        return true;
    }

    public function getLastInsertId() {
        return $this->pdo->lastInsertId();
    }
}
