From: Anton Blanchard <anton@samba.org>
Subject: send to self patch
Date: Mon, 22 Nov 2004 15:55:53 +1100
Message-ID: <20041122045553.GB32312@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

We've been using Julian Anastasov's send to self patch quite a lot. It
has been useful for a number of things including POWER5 system test
(where we stress a single system with a number of networks) through to
e1000 TSO testing more recently.

Are there any hopes of getting it merged? :)

http://www.ssi.bg/~ja/#loop

Anton
