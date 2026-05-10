<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<head>
<link href="${contextPath}/resources/css/bootstrap.min.css" rel="stylesheet">
    <link href="${contextPath}/resources/css/profile.css" rel="stylesheet">
  	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="https://bootswatch.com/cosmo/bootstrap.min.css">
	<link rel="stylesheet" href="${contextPath}/resources/css/w3.css">
</head>
<body>
<div class="container-fluid">
    <nav class="navbar navbar-custom navbar-static-top" role="navigation" style="background-color: #e3f2fd;">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="${contextPath}/index">Zaheer Ahmad</a>
            </div>
            <div class="navbar-collapse collapse">
                <ul class="nav navbar-nav">
                    <li><a href="#technologies">Technologies</a></li>
                    <li><a href="#about">About</a></li>
                    <li><a href="#contact">Contact</a></li>
                    <li><a href="#">Blog</a></li>
                </ul>
                <ul class="nav navbar-nav navbar-right">
                    <li><a href="${contextPath}">Login</a></li>
                    <li><a href="${contextPath}/registration">Sign up</a></li>
                </ul>
            </div>
        </div>
    </nav>
</div>
<!-- Header -->
<header class="w3-display-container w3-content w3-wide" style="max-width:1500px;" id="home">
  <img class="w3-image" src="${contextPath}/resources/Images/dev_img.jpeg" alt="Architecture" width="1500" height="800">
</header>
<div>
<blockquote><p>
     <h2 align="center" style="font-family: Verdana,sans-serif;color:#1C3B47;">Build. Automate. Deploy.</h2>
     <h3 align="center" style="font-family: Verdana,sans-serif;color:#1C3B47;">Infrastructure as Code | CI/CD | Cloud Native | Kubernetes</h3>
</blockquote>
<!-- Page content -->
<div class="w3-content w3-padding" style="max-width:1564px">

  <!-- Project Section -->
  <div class="container w3-padding-32" id="technologies">
    <h3 class="w3-border-bottom w3-border-light-grey w3-padding-16" align="center">TECHNOLOGIES</h3>
  </div>

  <div class="w3-row-padding">
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/Ansible_logo.png" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
         <img src="${contextPath}/resources/Images/technologies/aws.png" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/git.jpg" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/jenkins.png" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
  </div>

  <div class="w3-row-padding">
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/docker.png" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/puppet.jpg" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/Vagrant.png" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/python-logo.png" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
  </div>

  <!-- About Section -->
  <div class="container w3-padding-32" id="about">
    <h3 class="w3-border-bottom w3-border-light-grey w3-padding-16" align="center">ABOUT</h3>
    <div class="w3-content" style="max-width:864px">
	     <p style="text-align:justify;">
                    Zaheer Ahmad is a DevOps Engineer passionate about building scalable, automated, and resilient infrastructure. With hands-on experience in cloud platforms (AWS &amp; Azure), container orchestration (Kubernetes), and infrastructure as code (Terraform), he bridges the gap between development and operations.
                </p>
                <p style="text-align:justify;">
                    This platform is a multi-tier web application showcasing a complete DevOps stack — Nginx as reverse proxy, Apache Tomcat as the application server, MySQL for persistent storage, Memcached for caching, and RabbitMQ for message brokering. Provisioned with Vagrant and automated using shell scripts.
                </p>
                <p style="text-align:justify;">
                    From disaster recovery platforms on AWS with EKS and ArgoCD, to Azure-based business continuity solutions with Velero and Terraform — Zaheer builds production-grade infrastructure with a security-first, automation-first mindset.
                </p>
                <p style="text-align:justify;">
                    Currently working toward a portfolio of 100 real-world DevOps projects covering cloud, containers, CI/CD, monitoring, and more.
                </p>
                <p><strong>Location:</strong> Pakistan</p>
                <p><strong>GitHub:</strong> <a href="https://github.com/ZaheerrAhmed">github.com/ZaheerrAhmed</a></p>
                <p><strong>Email:</strong> zaheer.noor210@gmail.com</p>
  	</div>
   </div>

  <!-- Contact Section -->
  <div class="container w3-padding-32" id="contact">

    <h3 class="w3-border-bottom w3-border-light-grey w3-padding-16" align="center">CONTACT</h3>
    <div class="forms" id="contact-form">
    <p>Lets get in touch and talk about your and our next project.</p>
    <form action="/action_page.php" id="action" target="_blank">
      <input class="w3-input" type="text" placeholder="Name" required name="Name">
      <input class="w3-input w3-section" type="text" placeholder="Email" required name="Email">
      <input class="w3-input w3-section" type="text" placeholder="Subject" required name="Subject">
      <input class="w3-input w3-section" type="text" placeholder="Comment" required name="Comment">
      <button class="w3-button w3-black w3-section" type="submit">
        <i class="fa fa-paper-plane"></i> SEND MESSAGE
      </button>
    </form>
    </div>
  </div>

<!-- End page content -->





</body>
</html>

</body>