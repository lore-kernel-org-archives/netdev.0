From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] preempt count regression w/ lockless loopback patch
Date: Tue, 22 Jun 2004 12:39:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622123931.50d5ac05.davem@redhat.com>
References: <200406210510.i5L5A340018849@hera.kernel.org>
	<20040621035702.6114bdbe.akpm@osdl.org>
	<Pine.SGI.4.56.0406220913010.1334066@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, chrisw@osdl.org, gillb4@telusplanet.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.SGI.4.56.0406220913010.1334066@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004 09:24:40 -0700
Arthur Kepner <akepner@sgi.com> wrote:

> I made one small change in get_stats() and tested with a preemptible
> kernel on a 32p system. Looks good. The tested patch is attached.

Can you instead give a patch relative to Andrew's?  His is
applied already and in fact pushed into Linus's tree.
