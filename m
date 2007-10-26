From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Fri, 26 Oct 2007 04:06:31 -0700 (PDT)
Message-ID: <20071026.040631.89479668.davem@davemloft.net>
References: <471FAA03.9090003@hp.com>
	<OF03E20988.736A2E51-ON8825737E.007067FE-8825737E.0071B902@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, bunk@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755320AbXJZLGn@vger.kernel.org>
In-Reply-To: <OF03E20988.736A2E51-ON8825737E.007067FE-8825737E.0071B902@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 24 Oct 2007 13:43:14 -0700

> So, I stand corrected, and sorry about the histrionics. Since
> these are arguably ICMP errors, and since errors is the only
> thing being MIB-counted in DCCP and SCTP, then it now looks
> ok to me as-is, and also ok to remove icmpmsg_statistics from
> exporting.

I've applied Adrian's export removal patch, thanks!
