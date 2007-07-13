From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [Cbe-oss-dev] [PATCH] spidernet: don't use debug flag
Date: Fri, 13 Jul 2007 17:16:05 +0900 (JST)
Message-ID: <20070713.171605.-1300519026.kouish@swc.toshiba.co.jp>
References: <20070711203742.GI5549@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:36288 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882AbXGMIYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 04:24:39 -0400
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id l6D8Oarc020919
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 17:24:36 +0900 (JST)
In-Reply-To: <20070711203742.GI5549@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas-san,

> p.s. I tested ifdown/ifup, and didn't see any problems.
> Does your bug happen immediately, or does it take many attempts 
> to trigger it?

Thanks for your testing.

It happens immediately in our environment. It may be celleb specific.

Best regards,
Kou Ishizaki
