From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/7] [NET]: Change comment to describe the real meaning of IFF_RUNNING
Date: Mon, 28 Mar 2005 02:10:39 +0200
Message-ID: <20050328001039.GU3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:46:34+02:00 tgraf@suug.ch 
#   [NET]: Change comment to describe the real meaning of IFF_RUNNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# include/linux/if.h
#   2005/03/28 00:46:23+02:00 tgraf@suug.ch +1 -1
#   [NET]: Change comment to describe the real meaning of IFF_RUNNING
# 
diff -Nru a/include/linux/if.h b/include/linux/if.h
--- a/include/linux/if.h	2005-03-28 01:07:33 +02:00
+++ b/include/linux/if.h	2005-03-28 01:07:33 +02:00
@@ -33,7 +33,7 @@
 #define	IFF_LOOPBACK	0x8		/* is a loopback net		*/
 #define	IFF_POINTOPOINT	0x10		/* interface is has p-p link	*/
 #define	IFF_NOTRAILERS	0x20		/* avoid use of trailers	*/
-#define	IFF_RUNNING	0x40		/* resources allocated		*/
+#define	IFF_RUNNING	0x40		/* interface running and carrier ok */
 #define	IFF_NOARP	0x80		/* no ARP protocol		*/
 #define	IFF_PROMISC	0x100		/* receive all packets		*/
 #define	IFF_ALLMULTI	0x200		/* receive all multicast packets*/
