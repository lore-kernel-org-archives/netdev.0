From: "David S. Miller" <davem@redhat.com>
Subject: Re: netlink tester program
Date: Mon, 09 Jun 2003 10:16:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.101615.133898193.davem@redhat.com>
References: <20030603075742.34434.qmail@web14305.mail.yahoo.com>
	<20030608212033.Y33230@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: etsh_cucu@yahoo.com, david-b@pacbell.net, rddunlap@osdl.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030608212033.Y33230@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Sun, 8 Jun 2003 21:35:09 -0400 (EDT)

   Netlink2 draft is work in progress. The draft tends to lag reality.
   I believe what you refer to has been fixed. Refer to the slides at:
   http://www.zurich.ibm.com/~rha/netlink2.pdf
 ...   
   Consider netlink2 as a distributed netlink.

Beautiful, if you're going to allow this protocol to go over the wire,
you have to choose a network byte order and swap in/out of it.

Should be fun :)

Unfortunately I see no mention of this issue in the slides, should I
be scared?
