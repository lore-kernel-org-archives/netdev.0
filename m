From: "David S. Miller" <davem@redhat.com>
Subject: Re: Dump of TCP hang in established state
Date: Thu, 29 May 2003 14:54:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.145433.35666641.davem@redhat.com>
References: <20030529.024114.78714066.davem@redhat.com>
	<1054217010.757.39.camel@tux.rsn.bth.se>
	<1054238230.709.1.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gandalf@wlug.westbo.se
In-Reply-To: <1054238230.709.1.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Martin Josefsson <gandalf@wlug.westbo.se>
   Date: 29 May 2003 21:57:11 +0200
   
   I've just tested 2.5-bk and I can still reproduce it.

Can you get a tcpdump trace at the sender side for the complete life
of the connection for which the hang occurs?

There isn't much we can do about this without a trace.
