From: bob.olszewski@cmstk.com
Subject: (no subject)
Date: Tue, 8 Jul 2003 16:05:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <85256D5D.006E5858.00@spchar2.spcomstock.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=AsfbwQBSZ3ABPOlMYzrAmVy5BJLvMN0BWIEaZcE1AN429kY1IRvNzRqx"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=AsfbwQBSZ3ABPOlMYzrAmVy5BJLvMN0BWIEaZcE1AN429kY1IRvNzRqx
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline






Hi,
I caught your name on a site and was wondering if you had any advise on this
scenario.
I'm running HA on multi-networked server, one interface (eth1) 
--0__=AsfbwQBSZ3ABPOlMYzrAmVy5BJLvMN0BWIEaZcE1AN429kY1IRvNzRqx
Content-type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-transfer-encoding: quoted-printable


=A0is a member of
the HA group that customers connect to, the other (eth0) is where it ge=
ts its
feed from ( not running HA). =A0Problem I have, is if the feed source i=
nterface
(eth0) goes down the server can not deliver data.
I can not run eth0 in HA, our app. on the feed source side allows only =
one
connection.

Is there any way to config heartbeat to recognize that if a non-HA'd in=
terface
goes down to make the interface that "is" in an HA group fail over ?
=

--0__=AsfbwQBSZ3ABPOlMYzrAmVy5BJLvMN0BWIEaZcE1AN429kY1IRvNzRqx--
