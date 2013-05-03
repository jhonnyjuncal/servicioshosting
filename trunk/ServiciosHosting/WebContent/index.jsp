<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Date"%>
<%@page import="javax.sql.DataSource"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="net.sf.json.JSONObject"%>

<html>
	<head>
		<title>::: HOSTING JAVA :::</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<link href="http://www.hostingjava.it/style.css" rel="stylesheet" type="text/css">
	</head>
	
	<body>
		<%
			try{
				if(request.getParameter("consulta") != null){
					Integer consulta = Integer.parseInt(request.getParameter("consulta"));
					switch(consulta){
						case 0:
							JSONObject json = new JSONObject();
							String nombre = request.getParameter("nombre");
							String telefono = request.getParameter("telefono");
							String email = request.getParameter("email");
							String pais = request.getParameter("pais");
							JSONArray valores = funcionInsertarUsuarioNuevo(nombre, telefono, email, pais);
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
					}
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}
		%>
		
		
		<!-- FUNCION INSERTAR USUARIO NUEVO EN BBDD -->
		<%! JSONArray funcionInsertarUsuarioNuevo(String nombre, String telefono, String email, String pais){
			Connection con = null;
			JSONArray valor = null;
			Integer idUsuario = null;
			
			try{
				Class.forName("com.mysql.jdbc.Driver");
				String ruta = "jdbc:mysql://instance44663.db.xeround.com:5710/mpopular?user=jhonny&password=14743430";
				con = DriverManager.getConnection(ruta);
				
				PreparedStatement ps = con.prepareStatement("SELECT MAX(idUsuario) FROM usuarios");
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					idUsuario = rs.getInt(1);
    				idUsuario++;
				}
				
				ps = con.prepareStatement("INSERT INTO usuarios VALUES (?, ?, ?, ?, ?, now())");
				ps.setInt(1, idUsuario);
				ps.setString(2, nombre);
				ps.setString(3, telefono);
				ps.setString(4, email);
				ps.setString(5, pais);
				ps.executeUpdate();
				
				ps = con.prepareStatement("SELECT * FROM usuarios WHERE idUsuario = ?");
				ps.setInt(1, idUsuario);
				rs = ps.executeQuery();
				if(rs.next()){
					JSONArray arrayObj = new JSONArray();
					arrayObj.add(rs.getInt(1));
					arrayObj.add(rs.getString(2));
					arrayObj.add(rs.getString(3));
					arrayObj.add(rs.getString(4));
					arrayObj.add(rs.getString(5));
					valor = arrayObj;
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}finally{
				try{
					if(con != null)
						con.close();
				}catch(Exception ex){
					ex.printStackTrace();
				}
			}
			return valor;
		}; %>
		
    <div id="header"></div>
    <div id="container"> 
        <div id="colonnaSX">
            <div id="navcontainer"> <img src="http://www.hostingjava.it/images/freccia.gif" alt="freccia javahousing"> 
            </div>
            <div id="boxTalking">
                <!--codice talkwihtus-->
                <script language="javascript" src ='http://www.talkwithus.it/hostingjava/js/chatrequest.jsp'></script>
                <noscript>
                    <a href="javascript:twuopenu();"><img src='http://www.talkwithus.it/hostingjava/images/logo.gif'></a>
                </noscript>
                <!--fine codice talkwithus-->
            </div>
        </div>
        <div id="colonnaCXmax"> 
            <div id="titoli">Página de JHONNY JUNCAL GONZALEZ</div>
            <div id="titoliParagrafi">
                <br/>
                Página en construcción
                <br/>
            </div>
        </div>
        <div id="colonnaDX">
            <input type="image" src="http://www.hostingjava.it/images/javahousing_logo.gif" border="0" align="right"/>
        </div>
    </div>
    <div id="footer">
        <div id="credits">
            Powered by <a href="http://www.ilz.it" class="linkFooter">ILZ</a>
        </div>
    </div></body>
</html>
