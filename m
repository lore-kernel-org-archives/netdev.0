From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch iproute2] add quickack option to ip route
Date: Tue, 16 Jul 2013 10:29:32 +0800
Message-ID: <1373941772.25489.7.camel@cr0>
References: <1371260359-5875-1-git-send-email-amwang@redhat.com>
	 <1371260359-5875-2-git-send-email-amwang@redhat.com>
	 <20130619181722.50b2d7b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753613Ab3GPCaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jul 2013 22:30:17 -0400
In-Reply-To: <20130619181722.50b2d7b7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 18:17 -0700, Stephen Hemminger wrote:
> On Sat, 15 Jun 2013 09:39:19 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > This patch adds quickack option to enable/disable TCP quick ack
> > mode for per-route.
> > 
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Thomas Graf <tgraf@suug.ch>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> 
> I am still waiting until RTAX_QUICKACK is accepted into net-next to apply to net-next-3.10 branch
> of iproute
> 
> 

The kernel patch was already merged into Linus tree, so could you apply
it now? Do I need to resend it?

Thanks!
