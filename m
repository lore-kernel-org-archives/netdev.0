From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 28 Jul 2003 01:58:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307280158250677.10891156@192.168.128.16>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
 <200307280140470646.1078EC67@192.168.128.16>
 <20030727164649.517b2b88.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030727164649.517b2b88.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 27/07/2003 at 16:46 David S. Miller wrote:

>No, your problem was completely different.

The setting who show up the problem was different. The problem is the same.

>Bas's problem can be solved by him giving a "preferred source"
>to each of his IPV4 routes and setting the "arpfilter" sysctl
>variable for his devices to "1".

Yes, it's another approach to solve his problem. But he must play with routing.

With the "hidden patch" the only thing he needs is to switch the feature on.

Regards,
Carlos Velasco
