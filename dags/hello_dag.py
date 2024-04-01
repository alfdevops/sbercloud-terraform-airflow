from datetime import datetime

from airflow import DAG
from airflow.operators.bash_operator import BashOperator


dag = DAG(
    'test_dag',
    description='git-sync testing',
    schedule_interval=None,
    start_date=datetime(2024, 4, 1),
    catchup=False
)


hello_world_task = BashOperator(
    task_id='hello_world_task',
    bash_command='echo Hello world!',
    dag=dag
)

hello_world_task
