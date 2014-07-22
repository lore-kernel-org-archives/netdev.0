From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] bnx2x: Add FW 7.10.51
Date: Tue, 22 Jul 2014 04:38:21 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B028A1@avmb3.qlogic.org>
References: <1405403191-7517-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60832 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752819AbaGVEi4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 00:38:56 -0400
In-Reply-To: <1405403191-7517-1-git-send-email-Yuval.Mintz@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH] bnx2x: Add FW 7.10.51
>
> Hi,
>
> This firmware includes many fixes such as:
>
>  - (L2) In some multi-function configurations, inter-PF and inter-VF
>    Tx switching is incorrectly enabled.
>
>  - (L2) Wrong assert code in FLR final cleanup in case it is sent not
>    after FLR.
>
>  - (L2) Chip may stall in very rare cases under heavy traffic with FW GRO
>    enabled.
>
>  - (L2) VF malicious notification error fixes.
>
>  - (L2) Default gre tunnel to IPGRE which allows proper RSS for IPGRE packets,
>    L2GRE traffic will reach single queue.
>
>  - (FCoE) Fix data being placed in wrong buffer when corrupt FCoE frame is
>    received.
>
>  - (FCoE) Burst of FIP packets with destination MAC of ALL-FCF_MACs
>    causes FCoE traffic to stop.
>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Hi,

Any news about this one?

Thanks,
Yuval

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
