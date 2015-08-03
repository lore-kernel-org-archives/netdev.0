From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 0/4] bnx2x, cnic, bnx2fc: add support for BD
Date: Mon, 3 Aug 2015 13:09:31 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DF63D5@avmb3.qlogic.org>
References: <1438607016-25335-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "James.bottomley@HansenPartnership.com"
	<James.bottomley@HansenPartnership.com>,
	"linux-scsi-owner@vger.kernel.org" <linux-scsi-owner@vger.kernel.org>,
	Chad Dupuis <chad.dupuis@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33170 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753325AbbHCNJh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2015 09:09:37 -0400
In-Reply-To: <1438607016-25335-1-git-send-email-Yuval.Mintz@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Commit 230d00eb4bfe ("bnx2x: new Multi-function mode - BD") added support
> for a new multi-function mode, but it added only the support required by bnx2x
> for L2 interfaces.
> 
> This adds the required changes to support the new multi-function mode in the
> offloaded storage protocols.
> 
> Dave,
> 
> Please consider applying this series to `net-next'.
> 
> Do notice that this involves non-networking driver changes - but sending this as
> a single series seemed like the best approach as we had to have bnx2x changes
> to support the new functionality.
> If this is problematic, please tell us what's the preferred solution here.
> 
> Thanks,
> Yuval

Apparently I've made a typo in netdev's E-mail address.
Dave - do you want me to re-send the entire series?
