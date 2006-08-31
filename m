From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] change somaxconn sysctl to __read_mostly
Date: Thu, 31 Aug 2006 15:03:47 -0700 (PDT)
Message-ID: <20060831.150347.85399584.davem@davemloft.net>
References: <44F74815.5030006@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26553
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964769AbWHaWDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:03:41 -0400
To: brian.haley@hp.com
In-Reply-To: <44F74815.5030006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 31 Aug 2006 16:35:33 -0400

> Change sysctl_somaxconn to __read_mostly.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied.
