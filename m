From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25] reference counting for AX.25 routes.
Date: Mon, 03 Jul 2006 19:30:34 -0700 (PDT)
Message-ID: <20060703.193034.39152251.davem@davemloft.net>
References: <20060630133858.GA12180@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12732
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751367AbWGDCaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:30:18 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060630133858.GA12180@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 30 Jun 2006 14:38:58 +0100

> In the past routes could be freed even though the were possibly in use ...
> 
> Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

Applied.
