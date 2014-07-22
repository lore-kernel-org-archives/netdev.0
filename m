From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] bnx2x: Add FW 7.10.51
Date: Tue, 22 Jul 2014 09:14:57 +0200
Message-ID: <1406013297.10255.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405403191-7517-1-git-send-email-Yuval.Mintz@qlogic.com>
	 <B5657A6538887040AD3A81F1008BEC63B028A1@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "dwmw2@infradead.org" <dwmw2@infradead.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:53744 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGVHPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 03:15:12 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so5391875wib.4
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 00:15:11 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B028A1@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-22 at 04:38 +0000, Yuval Mintz wrote:
> > Subject: [PATCH] bnx2x: Add FW 7.10.51
> >
> > Hi,
> >
> > This firmware includes many fixes such as:
> >
> >  - (L2) In some multi-function configurations, inter-PF and inter-VF
> >    Tx switching is incorrectly enabled.
> >
> >  - (L2) Wrong assert code in FLR final cleanup in case it is sent not
> >    after FLR.
> >
> >  - (L2) Chip may stall in very rare cases under heavy traffic with FW GRO
> >    enabled.
> >
> >  - (L2) VF malicious notification error fixes.
> >
> >  - (L2) Default gre tunnel to IPGRE which allows proper RSS for IPGRE packets,
> >    L2GRE traffic will reach single queue.
> >
> >  - (FCoE) Fix data being placed in wrong buffer when corrupt FCoE frame is
> >    received.
> >
> >  - (FCoE) Burst of FIP packets with destination MAC of ALL-FCF_MACs
> >    causes FCoE traffic to stop.
> >
> > Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> > Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
> > Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> 
> Hi,
> 
> Any news about this one?

I cant find it in my mails... when was it sent ?
