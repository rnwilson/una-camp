# UNA-CAMP

#### Acknowledgements:

I have limited experience with Docker, PHP, Bash, and [UNA](https://una.io). There is no doubt one might have a better solution and I would really appreciate any thoughts on improving execution and best practices.

This has only been tested with the [base](https://github.com/unaio/una) UNA stack as I do not have any additional modules from the [App Market](https://una.io/page/products-home). I do not see forsee any limitations of functionality other than any modules requiring a reverse proxy but I reserve the right to be wrong.

#### Instructions:


1. Edit **.env.example** and make changes accordingly.
   
2. Make  **builder.sh** executable and run the script.
  
   **`chmod +x builder.sh && ./builder.sh`**  
   
3. Add DNS entries and generate SSL Certificates if you have not already done so. The hostname for the Apache server is **apache1** but you can change this to whatever you would like. **(cert1.pem, chain1.pem, fullchain1.pem, privkey1.pem)**
   
4. Run:
   
   **`COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up --build -d`**

#### Todo:

- PHP-FPM 
- Replace Apache 
- Reverse Proxy  
- Load Balancer    

