From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 17:07:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819170751.2b92ba2e.skraw@ithnet.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	<20030819145403.GA3407@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: richard@aspectgroup.co.uk, alan@lxorguk.ukuu.org.uk, davem@redhat.com,
   willy@w.ods.org, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, bloemsaa@xs4all.nl, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030819145403.GA3407@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 16:54:03 +0200
Willy Tarreau <willy@w.ods.org> wrote:

> This is exactly the case I calmly discussed privately with David then Alexey.
> Both explained me that in fact, the remote host shouldn't be filtering the
> ARP requests based on the source IP they provide,

Hm, what rule is broken by the remote host, then? I mean "remote host shouln't"
reads like "according to RFC-XYZ he should not".
IFF of course the remote host is not broken, then our idea must be broken. Else
world would have kind of a definition gap in this layer of networking, and I
hardly believe that.

Regards,
Stephan
