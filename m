From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 11:21:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819112103.373fce27.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5D@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: skraw@ithnet.com, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Underwood <richard@aspectgroup.co.uk>
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB5D@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 19:05:13 +0100
Richard Underwood <richard@aspectgroup.co.uk> wrote:

> 	The ARP request represents all FUTURE
> packets being sent out that interface, not just the one single packet that
> happened to kick of this ARP request.

That's RIGHT!  And by your own argument the source address
in the ARP request IS IRRELEVANT and is to be ignored!

Ok, I've lost 3 days of talking about ARP non-stop, I think
I'll take a break from these threads for a while, it's getting
to be a bit much.
