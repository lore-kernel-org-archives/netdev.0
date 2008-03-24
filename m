From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Mon, 24 Mar 2008 00:48:27 -0700 (PDT)
Message-ID: <20080324.004827.253759730.davem@davemloft.net>
References: <20080314122314.b877cfab.kazunori@miyazawa.org>
	<20080321.042048.198566667.davem@davemloft.net>
	<20080324161646.5e4ff0eb.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753050AbYCXHs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 03:48:27 -0400
In-Reply-To: <20080324161646.5e4ff0eb.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Mon, 24 Mar 2008 16:16:46 +0900

> Sorry for my late reply because of weekend :-)

How were the snow and surf conditions? :-)

> I removed the ifdef from the patch and I roughly tested
> with compling and doing IPsec for ICMP(v6) on the kernel.

Thank you, I will review this soon.
