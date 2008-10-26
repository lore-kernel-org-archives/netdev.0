From: "Huang Weiyi" <weiyi.huang@gmail.com>
Subject: [ofa-general] ***SPAM*** mlx4_en: remove duplicated #include
Date: Sun, 26 Oct 2008 23:05:42 +0800
Message-ID: <2a61071b0810260805o17e78c73q38d133d83e2f5ea8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1741543292=="
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rolandd@cisco.com, jgarzik@pobox.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

--===============1741543292==
Content-Type: multipart/alternative;
	boundary="----=_Part_64860_17356713.1225033542722"

------=_Part_64860_17356713.1225033542722
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Removed duplicated #include <linux/cpumask.h> in
drivers/net/mlx4/en_main.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 1b0eebf..4b9794e 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -35,7 +35,6 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-#include <linux/cpumask.h>

 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>

------=_Part_64860_17356713.1225033542722
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Removed duplicated #include &lt;linux/cpumask.h&gt; in<br>drivers/net/mlx4/en_main.c.<br>

<br>

Signed-off-by: Huang Weiyi &lt;<a href="mailto:weiyi.huang@gmail.com">weiyi.huang@gmail.com</a>&gt;<br><br>diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c<br>index 1b0eebf..4b9794e 100644<br>--- a/drivers/net/mlx4/en_main.c<br>
+++ b/drivers/net/mlx4/en_main.c<br>@@ -35,7 +35,6 @@<br>&nbsp;#include &lt;linux/module.h&gt;<br>&nbsp;#include &lt;linux/delay.h&gt;<br>&nbsp;#include &lt;linux/netdevice.h&gt;<br>-#include &lt;linux/cpumask.h&gt;<br><br>&nbsp;#include &lt;linux/mlx4/driver.h&gt;<br>
&nbsp;#include &lt;linux/mlx4/device.h&gt;<br><br>

------=_Part_64860_17356713.1225033542722--

--===============1741543292==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1741543292==--
