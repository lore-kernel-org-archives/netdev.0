From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 09:56:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819095611.0fb8f9a3.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
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
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 13:02:20 +0100
Richard Underwood <richard@aspectgroup.co.uk> wrote:

> David S. Miller wrote:
> > Under Linux, by default, IP addresses are owned by the system
> > not by interfaces.  This increases the likelyhood of successful
> > communication on a subnet.
> > 
> 	This is crap.

Nope, the RFCs allow this.

So this is where we must agree to disagree.  Because host ownership of
IP addresses is the basis for all of the arguments and it completely
justifies Linux's ARP behavior on both sides.
