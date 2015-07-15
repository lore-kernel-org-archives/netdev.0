From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] bnx2x: Update to FW version 7.12.30
Date: Wed, 15 Jul 2015 04:50:55 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DE80A2@avmb3.qlogic.org>
References: <1434866091-30087-1-git-send-email-Yuval.Mintz@qlogic.com>
 <B5657A6538887040AD3A81F1008BEC63DD93BB@avmb3.qlogic.org>
 <B5657A6538887040AD3A81F1008BEC63DE5037@avmb3.qlogic.org>
 <B5657A6538887040AD3A81F1008BEC63DE54D0@avmb3.qlogic.org>
 <20150714210449.GV13281@merlin.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Kyle McMartin <kyle@infradead.org>,
	"linux-firmware@kernel.org" <linux-firmware@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:48497 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751365AbbGOEvW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 00:51:22 -0400
In-Reply-To: <20150714210449.GV13281@merlin.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: Re: [PATCH] bnx2x: Update to FW version 7.12.30
> 
> On Mon, Jul 13, 2015 at 10:17:24AM +0000, Yuval Mintz wrote:
> > > > > The new FW will allow us to utilize some new features in our
> > > > > driver, mainly adding vlan filtering offload and vxlan offload support.
> > > > >
> > > > > In addition, this fixes several issues:
> > > > > 1. Packets from a VF with pvid configured which were sent with a
> > > > >    different vlan were transmitted instead of being discarded.
> > > > >
> > > > > 2. FCoE traffic might not recover after a failue while there's traffic
> > > > >    to another function.
> > > > >
> > > > > Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> > > >
> > > > Hi, any news about this one?
> > > > Thanks, Yuval
> > >
> > > Any updates? I've sent this 3-weeks ago and haven't seen any reply.
> >
> > Apparently the destination E-mail has changed and I was unaware.
> > Is anyone here? ;-)
> >
> 
> Hmm?
> 
> --Kyle

Hi Kyle,

I've sent a new bnx2x FW ~3 weeks ago, but I wasn't aware of the
change in E-mails and that I was supposed to send it to linux-firmware,
so I addressed it to David/Ben as I used to in the past.
And I haven't seen any reply to it.

Should I re-send the FW patch to linux-firmware?

Thanks,
Yuval
