From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 17 Aug 2003 18:45:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308171845560303.00D4B163@192.168.128.16>
References: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com>
 <20030728213933.F81299@coredump.scriptkiddie.org>
 <200308171509570955.003E4FEC@192.168.128.16>
 <200308171516090038.0043F977@192.168.128.16>
 <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
 <200308171555280781.0067FB36@192.168.128.16>
 <1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
 <200308171759540391.00AA8CAB@192.168.128.16>
 <3F3FB275.3090601@davehollis.com>
Content-Type: text/plain; charset="ISO-8859-1"
Cc: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
   "Lamont Granquist" <lamont@scriptkiddie.org>,
   "Bill Davidsen" <davidsen@tmr.com>, "David S. Miller" <davem@redhat.com>,
   bloemsaa@xs4all.nl, "Marcelo Tosatti" <marcelo@conectiva.com.br>,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org,
   "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <3F3FB275.3090601@davehollis.com>
To: "David T Hollis" <dhollis@davehollis.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17/08/2003 at 12:51 David T Hollis wrote:

>Check out: http://www.linuxvirtualserver.org/docs/arp.html.  I 
>understand the problem you're talking about.  It's not a 'bug', it's a

>feature!  You need to use the hidden interface approach to have the
back 
>end system not broadcast it's MAC for the virtual IP.

I know it... but..

1. hidden patch is not in the main linuk kernel stream.... why?
2. that "feature" makes linux to send non-RFC ARP Requests
3. what's the meaning of that "feature"? It seems to do more problems
that it solves.

Regards,
Carlos Velasco
