From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: Possible leak of multicast source filter sctructure
Date: Thu, 17 Aug 2006 16:29:14 -0700 (PDT)
Message-ID: <20060817.162914.92584092.davem@davemloft.net>
References: <20060815.002139.107685177.davem@davemloft.net>
	<OF0DDEC0BC.F489C923-ON882571CB.0082F373-882571CB.0083A630@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, michal.ruzicka@comstar.cz,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30934
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030364AbWHQX3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 19:29:06 -0400
To: dlstevens@us.ibm.com
In-Reply-To: <OF0DDEC0BC.F489C923-ON882571CB.0082F373-882571CB.0083A630@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 15 Aug 2006 17:57:58 -0600

> Here's a patch to fix source filter leakage when a device is removed
> and a process leaves the group thereafter. (2nd part of prior discussion)
> 
> This patch also includes corresponding fixes for IPv6 multicast source
> filters on device removal (1st & 2nd parts of prior discussion, for IPv6).
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Patch applied, thanks David.

