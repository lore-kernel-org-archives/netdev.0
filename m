From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 28 Jul 2003 02:53:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307280253090799.10BB2DF0@192.168.128.16>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
 <200307280140470646.1078EC67@192.168.128.16>
 <20030727164649.517b2b88.davem@redhat.com>
 <200307280158250677.10891156@192.168.128.16>
 <20030727165831.05904792.davem@redhat.com>
 <200307280211590888.10957DD9@192.168.128.16>
 <20030727171403.6e5bcc58.davem@redhat.com>
 <200307280235210263.10AADFF8@192.168.128.16>
 <20030727173600.475d95fb.davem@redhat.com>
Content-Type: text/plain; charset="us-ascii"
Cc: bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030727173600.475d95fb.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 27/07/2003 at 17:36 David S. Miller wrote:

>> The easy way is the "hidden" patch, if it's applied in the kernel.
>
>Not true, anyone is free to design a graphical GUI or shell script (or
>even a wrapper for the /sbin/ip tool) that gives you the default
>behavior you want, without any user interaction whatsoever.

Anyone is free to do many things.
But if the hidden patch and /proc switch would be in the main kernel,
it would be the simpliest way to solve all these "problems" (with an
echo "1" and without filtering or using iproute2).

Regards,
Carlos Velasco
 
