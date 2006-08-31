From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] change max_dgram_qlen sysctl to __read_mostly
Date: Thu, 31 Aug 2006 15:03:51 -0700 (PDT)
Message-ID: <20060831.150351.85705924.davem@davemloft.net>
References: <44F74819.4070902@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27577
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964788AbWHaWDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:03:46 -0400
To: brian.haley@hp.com
In-Reply-To: <44F74819.4070902@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 31 Aug 2006 16:35:37 -0400

> Change AF_UNIX sysctl_unix_max_dgram_qlen to __read_mostly.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied.
