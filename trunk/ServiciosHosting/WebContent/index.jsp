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
		<title>::: JHONNY JUNCAL GONZALEZ :::</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<link href="http://www.hostingjava.it/style.css" rel="stylesheet" type="text/css">
	</head>
	
	<body>
		<%
			try{
				if(request.getParameter("consulta") != null){
					Integer consulta = Integer.parseInt(request.getParameter("consulta"));
					JSONObject json = new JSONObject();
					JSONArray valores = null;
					
					switch(consulta){
						case 0:
							String nombre1 = request.getParameter("nombre");
							String telefono = request.getParameter("telefono");
							String email = request.getParameter("email");
							String pais = request.getParameter("pais");
							
							valores = funcionInsertarUsuarioNuevo(nombre1, telefono, email, pais);
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
						case 1:
							valores = funcionConsultaRedesSociales();
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
						case 2:
							Integer idRed1 = Integer.parseInt(request.getParameter("idRed"));
							String usuario = request.getParameter("nombre");
							
							valores = funcionBuscaUsuariosRedes(usuario, idRed1);
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
						case 3:
							Integer idRed2 = Integer.parseInt(request.getParameter("idRed"));
							Integer idUsuario1 = Integer.parseInt(request.getParameter("idUsuario"));
							String nombre2 = request.getParameter("nombre");
							
							valores = funcionInsertarCuentaNueva(idRed2, idUsuario1, nombre2);
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
						case 4:
							Integer idUsuario2 = Integer.parseInt(request.getParameter("idUsuario"));
							
							valores = funcionConsultaCuentaUsuario(idUsuario2);
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
						case 5:
							Integer idUsuario3 = Integer.parseInt(request.getParameter("idUsuario"));
							
							valores = funcionConsultaDatosUsuario(idUsuario3);
							json.put("valores", valores);
							response.getWriter().write(json.toString());
							break;
					}
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}
		%>
		
		
		<!-- FUNCION CREAR CONEXION -->
		<%! Connection creaConexion(){
			Connection con = null;
			
			try{
				//opcion 1
				//Class.forName("com.mysql.jdbc.Driver");
				Class.forName("org.hsqldb.jdbcDriver");
				
				//String ruta = "jdbc:mysql:/home/hostingjava.it/jhonnyjuncal?user=jhonnyjuncal&password=#@jho11nny#@";
				//String ruta = "jdbc:hsqldb:file:/home/hostingjava.it/jhonnyjuncal/WEB-INF/lib/hsqldb";
				//String ruta = "jdbc:mysql://instance44663.db.xeround.com:5710/mpopular?user=jhonny&password=14743430";
				String ruta = "jdbc:hsqldb:file:/home/hostingjava.it/jhonnyjuncal/WEB-INF/lib/hsqldb";
				
				con = DriverManager.getConnection(ruta);
			}catch(Exception ex){
				ex.printStackTrace();
			}
			return con;
		}; %>
		
		
		<!-- FUNCION INSERTAR USUARIO NUEVO EN BBDD -->
		<%! JSONArray funcionInsertarUsuarioNuevo(String nombre, String telefono, String email, String pais){
			Connection con = null;
			JSONArray valor = null;
			Integer idUsuario = null;
			
			try{
				con = creaConexion();
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
		
		
		<!-- FUNCION CONSULTA LAS REDES SOCIALES EN BBDD -->
		<%! JSONArray funcionConsultaRedesSociales(){
			Connection con = null;
			JSONArray valor = null;
			
			try{
				con = creaConexion();
				PreparedStatement ps = con.prepareStatement("SELECT * FROM redes ORDER BY idRed");
				ResultSet rs = ps.executeQuery();
				JSONArray arrayObj = new JSONArray();
				
				while(rs.next()){
					arrayObj.add(rs.getInt(1));
					arrayObj.add(rs.getString(2));
				}
				
				valor = arrayObj;
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
		
		
		<!-- FUNCION CONSULTA DE DATOS DE USUARIO -->
		<%! JSONArray funcionBuscaUsuariosRedes(String nombre, Integer idRed){
			Connection con = null;
			JSONArray valor = null;
			
			try{
				con = creaConexion();
				String sql = "SELECT nombre " +
							"FROM usuarios AS u" +
							"INNER JOIN cuentas AS c ON c.idUsuario = u.idUsuario " +
							"INNER JOIN redes AS r ON r.idRed = c.idRed " +
							"WHERE nombre LIKE %?%";
				if(idRed > 0)
					sql += "AND r.idRed = ? ";
				
				PreparedStatement ps = con.prepareStatement(sql);
				ps.setString(1, nombre);
				if(idRed > 0)
					ps.setInt(2, idRed);
				ResultSet rs = ps.executeQuery();
				
				JSONArray arrayObj = new JSONArray();
				
				while(rs.next()){
					arrayObj.add(rs.getString(1));
				}
				
				valor = arrayObj;
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
		
		
		<!-- FUNCION INSERTAR CUENTA NUEVA EN BBDD -->
		<%! JSONArray funcionInsertarCuentaNueva(Integer idRed, Integer idUsuario, String nombre){
			Connection con = null;
			JSONArray valor = null;
			
			try{
				con = creaConexion();
				String sql = "INSERT INTO cuentas VALUES(null, ?, ?, ?)";
				PreparedStatement ps = con.prepareStatement(sql);
				ps.setInt(1, idRed);
				ps.setInt(2, idUsuario);
				ps.setString(3, nombre);
				ps.executeUpdate();
				
				sql = "SELECT * FROM cuentas WHERE idRed = ? AND idUsuario = ? AND nombre = ?";
				ps = con.prepareStatement(sql);
				ps.setInt(1, idRed);
				ps.setInt(2, idUsuario);
				ps.setString(3, nombre);
				ResultSet rs = ps.executeQuery();
				
				JSONArray arrayObj = new JSONArray();
				
				if(rs.next()){
					arrayObj.add(rs.getInt(1));
					arrayObj.add(rs.getInt(2));
					arrayObj.add(rs.getInt(3));
					arrayObj.add(rs.getString(4));
				}
				
				valor = arrayObj;
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
		
		
		<!-- FUNCION CONSULTAR CUENTAS DE USUARIO EN BBDD -->
		<%! JSONArray funcionConsultaCuentaUsuario(Integer idUsuario){
			Connection con = null;
			JSONArray valor = null;
			
			try{
				con = creaConexion();
				String sql = "SELECT c.nombre, r.nombre FROM cuentas AS c " +
							"INNER JOIN redes AS r ON r.idRed = c.idRed " +
							"WHERE c.idUsuario = ? ";
				PreparedStatement ps = con.prepareStatement(sql);
				ps.setInt(1, idUsuario);
				ResultSet rs = ps.executeQuery();
				
				JSONArray arrayObj = new JSONArray();
				while(rs.next()){
					arrayObj.add(rs.getString(1));
					arrayObj.add(rs.getString(2));
				}
				valor = arrayObj;
			}catch(Exception ex){
				ex.printStackTrace();
			}
			return valor;
		}; %>
		
		
		<!-- FUNCION CONSULTAR DATOS DE USUARIO EN BBDD -->
		<%! JSONArray funcionConsultaDatosUsuario(Integer idUsuario){
			Connection con = null;
			JSONArray valor = null;
			
			try{
				con = creaConexion();
				String sql = "SELECT * FROM usuarios WHERE idUsuario = ?";
				PreparedStatement ps = con.prepareStatement(sql);
				ps.setInt(1, idUsuario);
				ResultSet rs = ps.executeQuery();
				
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
                Esta pagina contendra la informacion necesaria para las aplicaciones android que estoy desarrollando.<br/>
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
