From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 23:31:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.233122.27808829.davem@redhat.com>
References: <20030608.050500.28795668.davem@redhat.com>
	<874r30r9z2.fsf@deneb.enyo.de>
	<1055214346.1199.65.camel@photon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: slblake@petri-meat.com
In-Reply-To: <1055214346.1199.65.camel@photon>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Steven Blake <slblake@petri-meat.com>
   Date: 09 Jun 2003 23:05:47 -0400

   http://www.petri-meat.com/slblake/networking/refs/lpm_pkt-class/
   
Interesting link, thanks for mentioning it.

   IMHO, the best LPM algorithm (in terms of balancing lookup speed vs.
   memory consumption vs. update rate) is CRT, described in the first paper
   [ASIK].  It is patented, but there is hope that it might get released
   under GPL in the near future.

It would be nice if this actually was a "paper", but it's
a patent entry, such things are always so cryptic.  Is there
a real paper on this scheme?
