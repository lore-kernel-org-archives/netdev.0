From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25] Use kzalloc
Date: Sun, 09 Jul 2006 12:14:31 -0700 (PDT)
Message-ID: <20060709.121431.102927671.davem@davemloft.net>
References: <20060709015200.GA6221@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32996
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161065AbWGITN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 15:13:59 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060709015200.GA6221@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sun, 9 Jul 2006 02:52:00 +0100

> Replace kzalloc instead of kmalloc + memset.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
