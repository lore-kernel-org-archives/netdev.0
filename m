From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] bnx2x: Update to FW version 7.12.30
Date: Sun, 5 Jul 2015 05:00:59 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DD93BB@avmb3.qlogic.org>
References: <1434866091-30087-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: "dwmw2@infradead.org" <dwmw2@infradead.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34140 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753320AbbGEIkJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2015 04:40:09 -0400
In-Reply-To: <1434866091-30087-1-git-send-email-Yuval.Mintz@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The new FW will allow us to utilize some new features in our driver,
> mainly adding vlan filtering offload and vxlan offload support.
> 
> In addition, this fixes several issues:
> 1. Packets from a VF with pvid configured which were sent with a
>    different vlan were transmitted instead of being discarded.
> 
> 2. FCoE traffic might not recover after a failue while there's traffic
>    to another function.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Hi, any news about this one?
Thanks, Yuval
