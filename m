From: "Zhenyu Wu" <y030729@njupt.edu.cn>
Subject: A Question On CBQ
Date: Sun, 02 Jan 2005 11:17:09 +0800
Message-ID: <304635829.27548@njupt.edu.cn>
Reply-To: "Zhenyu Wu" <y030729@njupt.edu.cn>
Content-Type: text/plain
Cc: lartc@mailman.ds9a.nl, tgraf@suug.ch
Return-path: <lartc-admin@mailman.ds9a.nl>
To: netdev@oss.sgi.com
Sender: lartc-admin@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Hello,

As it is well know that CBQ is the class based queue. But i am confused on the
word "class" now, especially it is used in Diffserv. IMO, different classes should
mean that there are different kinds of traffics, so the class should be difined by
the parameters (such as bandwidth, priority..) the traffic wanted. That is, using
cbq we can define different kinds of traffics which need different bandwidth at
the gateway, am i right??

Then, in diffserv the traffic is identified by the DSCP, right? From Floyd's paper
Link-sharing and Resource Management Models for Packet Networks, we can see if
there are two classes of traffic such as class A and class B, and each of them has
traffics video and ftp, then how the two different FTP are identified in diffserv,
by their DSCP? IMO, at first, according to the bandwidth the traffic needed, the
traffic is classified into class A or class B, then at each class the traffic is
identified by their DSCP.

Eagerly waiting for your reply!
Happy New Year!


_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
