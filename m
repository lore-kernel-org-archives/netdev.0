From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: e1000 in 2.4.21 and carrier errors
Date: Wed, 2 Jul 2003 10:59:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7BFCE5F1EF28D64198522688F5449D5A01FF2AF7@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We started running 2.4.21 and use the
e1000 driver in the kernel. Our NICs are
PRO-1000 82543GC based copper. Using the
new driver we see constant increase in
carrier errors. Loading the Intel
e1000 v3.6.8.1 driver we have no carrier errors.
This happens on all our systems with the
PR0-1000 card using 2.4.21 and RH9. Switches
are a mixture of Dell, Asante, Cisco, and Extreme.

Any ideas?

thanks

larry
