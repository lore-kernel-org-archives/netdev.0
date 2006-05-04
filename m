From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Eleminate HZ from NET/ROM kernel interfaces
Date: Wed, 03 May 2006 23:27:55 -0700 (PDT)
Message-ID: <20060503.232755.84120517.davem@davemloft.net>
References: <20060429141613.GA2811@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28850
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751418AbWEDG2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:28:18 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060429141613.GA2811@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 29 Apr 2006 15:16:13 +0100

> Convert all NET/ROM sysctl time values from jiffies to ms as units.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
