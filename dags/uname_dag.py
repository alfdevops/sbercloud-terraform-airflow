from datetime import datetime

from airflow import DAG
from airflow.operators.bash_operator import BashOperator


dag = DAG(
    'uname_dag',
    description='uname test',
    schedule_interval='*/5 * * * *',
    start_date=datetime(2024, 4, 1),
    catchup=False
)


uname_task = BashOperator(
    task_id='uname_task',
    bash_command="uname -a",
    dag=dag
)

uname_task
