From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] preempt count regression w/ lockless loopback patch
Date: Tue, 22 Jun 2004 14:01:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622140140.66b26cd1.davem@redhat.com>
References: <200406210510.i5L5A340018849@hera.kernel.org>
	<20040621035702.6114bdbe.akpm@osdl.org>
	<Pine.SGI.4.56.0406220913010.1334066@neteng.engr.sgi.com>
	<20040622123931.50d5ac05.davem@redhat.com>
	<Pine.SGI.4.56.0406221344380.1357620@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, chrisw@osdl.org, gillb4@telusplanet.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.SGI.4.56.0406221344380.1357620@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004 13:46:07 -0700
Arthur Kepner <akepner@sgi.com> wrote:

> On Tue, 22 Jun 2004, David S. Miller wrote:
> 
> > ....
> > Can you instead give a patch relative to Andrew's?  His is
> > applied already and in fact pushed into Linus's tree.
> >
> 
> Yes. It is in the attachment.

Thanks a lot Arthur, patch applied.
