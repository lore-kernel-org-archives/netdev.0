From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] bnx2x: Update to FW version 7.12.30
Date: Mon, 13 Jul 2015 10:17:24 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DE54D0@avmb3.qlogic.org>
References: <1434866091-30087-1-git-send-email-Yuval.Mintz@qlogic.com>
 <B5657A6538887040AD3A81F1008BEC63DD93BB@avmb3.qlogic.org>
 <B5657A6538887040AD3A81F1008BEC63DE5037@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: "linux-firmware@kernel.org" <linux-firmware@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:63283 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751636AbbGMKR2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 06:17:28 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63DE5037@avmb3.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > The new FW will allow us to utilize some new features in our driver,
> > > mainly adding vlan filtering offload and vxlan offload support.
> > >
> > > In addition, this fixes several issues:
> > > 1. Packets from a VF with pvid configured which were sent with a
> > >    different vlan were transmitted instead of being discarded.
> > >
> > > 2. FCoE traffic might not recover after a failue while there's traffic
> > >    to another function.
> > >
> > > Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> >
> > Hi, any news about this one?
> > Thanks, Yuval
> 
> Any updates? I've sent this 3-weeks ago and haven't seen any reply.

Apparently the destination E-mail has changed and I was unaware.
Is anyone here? ;-)
