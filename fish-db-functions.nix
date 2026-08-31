{ config, pkgs, ... }:

{
  xdg.configFile."fish/functions/mysql.fish".text = ''
    function mysql
        set -l DB_DIR "$HOME/mysql-data"

        if test "$argv[1]" = "start"
            if pgrep -x mysqld > /dev/null
                echo "MySQL is already running."
            else
                echo "Starting MySQL..."
                /usr/sbin/mysqld --no-defaults \
                    --datadir=$DB_DIR \
                    --socket=$DB_DIR/mysql.sock \
                    --mysqlx-socket=$DB_DIR/mysqlx.sock \
                    --pid-file=$DB_DIR/mysql.pid \
                    --port=3306 > $DB_DIR/mysql.log 2>&1 &
                echo "MySQL started in the background."
            end

        else if test "$argv[1]" = "stop"
            if test -f $DB_DIR/mysql.pid
                echo "Stopping MySQL..."
                kill (cat $DB_DIR/mysql.pid)
                sleep 1
                rm -f $DB_DIR/mysql.pid
                echo "MySQL stopped."
            else if pgrep -x mysqld > /dev/null
                echo "PID file missing, but process found. Killing mysqld..."
                pkill -x mysqld
            else
                echo "MySQL is not running."
            end

        else if test "$argv[1]" = "status"
            if pgrep -x mysqld > /dev/null
                echo "MySQL is RUNNING."
            else
                echo "MySQL is STOPPED."
            end

        else
            command mysql $argv
        end
    end
  '';

  xdg.configFile."fish/functions/mongodb.fish".text = ''
    function mongodb
        set -l DB_DIR "$HOME/mongo-data"

        if test "$argv[1]" = "start"
            if pgrep -x mongod > /dev/null
                echo "MongoDB is already running."
            else
                echo "Starting MongoDB..."
                mongod --dbpath $DB_DIR \
                       --logpath $DB_DIR/mongod.log \
                       --pidfilepath $DB_DIR/mongod.pid \
                       --fork
            end

        else if test "$argv[1]" = "stop"
            if pgrep -x mongod > /dev/null
                echo "Stopping MongoDB gracefully..."
                mongod --dbpath $DB_DIR --shutdown > /dev/null 2>&1
                echo "MongoDB stopped."
            else
                echo "MongoDB is not running."
            end

        else if test "$argv[1]" = "status"
            if pgrep -x mongod > /dev/null
                echo "MongoDB is RUNNING."
            else
                echo "MongoDB is STOPPED."
            end

        else
            command mongosh $argv
        end
    end
  '';

  xdg.configFile."fish/functions/redis.fish".text = ''
    function redis
        set -l DB_DIR "$HOME/redis-data"

        if test "$argv[1]" = "start"
            if pgrep -x redis-server > /dev/null
                echo "Redis is already running."
            else
                echo "Starting Redis..."
                redis-server --dir $DB_DIR \
                             --dbfilename dump.rdb \
                             --logfile $DB_DIR/redis.log \
                             --pidfile $DB_DIR/redis.pid \
                             --daemonize yes
                echo "Redis started in the background."
            end

        else if test "$argv[1]" = "stop"
            if pgrep -x redis-server > /dev/null
                echo "Stopping Redis gracefully..."
                redis-cli shutdown 2>/dev/null; or true
                echo "Redis stopped."
            else
                echo "Redis is not running."
            end

        else if test "$argv[1]" = "status"
            if pgrep -x redis-server > /dev/null
                echo "Redis is RUNNING."
            else
                echo "Redis is STOPPED."
            end

        else
            command redis-cli $argv
        end
    end
  '';

  xdg.configFile."fish/functions/cassandra.fish".text = ''
    function cassandra
        set -l DB_DIR "$HOME/cassandra-data"

        if test "$argv[1]" = "start"
            if pgrep -f "CassandraDaemon" > /dev/null
                echo "Cassandra is already running."
            else
                echo "Starting Cassandra..."
                env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
                    CASSANDRA_INCLUDE=$DB_DIR/cassandra.in.sh \
                    CASSANDRA_LOG_DIR=$DB_DIR/logs \
                    cassandra -p $DB_DIR/cassandra.pid > $DB_DIR/logs/startup.log 2>&1
                echo "Cassandra started in the background. (startup output: $DB_DIR/logs/startup.log)"
            end
        else if test "$argv[1]" = "stop"
            if test -f $DB_DIR/cassandra.pid
                echo "Stopping Cassandra..."
                kill (cat $DB_DIR/cassandra.pid)
                sleep 3
                rm -f $DB_DIR/cassandra.pid
                echo "Cassandra stopped."
            else if pgrep -f "CassandraDaemon" > /dev/null
                echo "PID file missing, but process found. Killing..."
                pkill -f "CassandraDaemon"
            else
                echo "Cassandra is not running."
            end
        else if test "$argv[1]" = "status"
            if pgrep -f "CassandraDaemon" > /dev/null
                echo "Cassandra is RUNNING."
            else
                echo "Cassandra is STOPPED."
            end
        else
            command cqlsh $argv
        end
    end
  '';

  xdg.configFile."fish/functions/neo4j.fish".text = ''
    function neo4j
        set -l NEO4J_HOME "$HOME/neo4j-data"
        set -l JAVA_HOME "/usr/lib/jvm/java-21-openjdk-amd64"
        set -l PIDFILE "$NEO4J_HOME/run/neo4j.pid"

        # Pass the PIDFILE as an argument to bypass block-scope limits
        function __neo4j_is_running -a target_pidfile
            if test -n "$target_pidfile"; and test -f "$target_pidfile"
                set -l NPID (cat "$target_pidfile" 2>/dev/null)
                if test -n "$NPID"
                    kill -0 $NPID 2>/dev/null
                    return $status
                end
            end
            return 1
        end

        if test "$argv[1]" = "start"
            if __neo4j_is_running $PIDFILE
                echo "Neo4j is already running."
            else
                echo "Starting Neo4j..."
                env JAVA_HOME=$JAVA_HOME NEO4J_HOME=$NEO4J_HOME $NEO4J_HOME/bin/neo4j start
            end
        else if test "$argv[1]" = "stop"
            if __neo4j_is_running $PIDFILE
                echo "Stopping Neo4j gracefully..."
                env JAVA_HOME=$JAVA_HOME NEO4J_HOME=$NEO4J_HOME $NEO4J_HOME/bin/neo4j stop
            else
                echo "Neo4j is not running."
            end
        else if test "$argv[1]" = "status"
            if __neo4j_is_running $PIDFILE
                echo "Neo4j is RUNNING."
            else
                echo "Neo4j is STOPPED."
            end
        else if test "$argv[1]" = "console"
            env JAVA_HOME=$JAVA_HOME NEO4J_HOME=$NEO4J_HOME $NEO4J_HOME/bin/neo4j console
        else
            env JAVA_HOME=$JAVA_HOME $NEO4J_HOME/bin/cypher-shell $argv
        end
    end
  '';
}
