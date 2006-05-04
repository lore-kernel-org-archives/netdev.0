From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Eleminate HZ from AX.25 kernel interfaces
Date: Wed, 03 May 2006 23:27:25 -0700 (PDT)
Message-ID: <20060503.232725.50820139.davem@davemloft.net>
References: <20060429141244.GA2407@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34228
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751412AbWEDG1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:27:44 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060429141244.GA2407@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Date: Sat, 29 Apr 2006 15:12:44 +0100

> Convert all AX.25 sysctl time values from jiffies to ms as units.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
