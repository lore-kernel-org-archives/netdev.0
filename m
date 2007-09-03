From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH -mm 2/2] 3c59x MAINTAINERS
Date: Tue, 4 Sep 2007 03:52:50 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709040351310.8504@enigma.security.iitk.ac.in>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in
 >
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756018AbXICWJx@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove duplicate entry for the same driver.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 MAINTAINERS |    6 ------
 1 file changed, 6 deletions(-)

--- linux-2.6.23-rc4-mm1/MAINTAINERS~fix	2007-09-04 03:49:16.000000000 +0530
+++ linux-2.6.23-rc4-mm1/MAINTAINERS	2007-09-04 03:49:28.000000000 +0530
@@ -104,12 +104,6 @@ M:	klassert@mathematik.tu-chemnitz.de
 L:	netdev@vger.kernel.org
 S:	Maintained
 
-3C59X NETWORK DRIVER
-P:	Steffen Klassert
-M:	klassert@mathematik.tu-chemnitz.de
-L:	netdev@vger.kernel.org
-S:	Maintained
-
 3CR990 NETWORK DRIVER
 P:	David Dillow
 M:	dave@thedillows.org
