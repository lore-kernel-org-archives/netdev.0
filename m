From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 19 Aug 2003 20:04:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061319864.30565.52.camel@dhcp23.swansea.linux.org.uk>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	 <20030819145403.GA3407@alpha.home.local>
	 <20030819170751.2b92ba2e.skraw@ithnet.com>
	 <20030819085717.56046afd.davem@redhat.com>
	 <20030819185219.116fd259.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, willy@w.ods.org,
   richard@aspectgroup.co.uk, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, bloemsaa@xs4all.nl,
   Marcelo Tosatti <marcelo@conectiva.com.br>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephan von Krawczynski <skraw@ithnet.com>
In-Reply-To: <20030819185219.116fd259.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Maw, 2003-08-19 at 17:52, Stephan von Krawczynski wrote:
> <quote RFC-985>

Effectively Obsolete.

>       An ARP reply is discarded if the destination IP address does not
>       match the local host address.  An ARP request is discarded if the

The local host address. Singular. Back from the days where addresses
lived by box
