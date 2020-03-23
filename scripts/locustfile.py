from locust import HttpLocust, TaskSet, task

class BasicTaskSet(TaskSet):

    #
    # ただトップページをGETするだけのテスト
    #
    @task(1)
    def root(self):
        self.client.get('/')

class BasicTasks(HttpLocust):
    task_set = BasicTaskSet
    # 1sec
    min_wait = 1000
    max_wait = 1000