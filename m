From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 16:08:07 -0700 (PDT)
Message-ID: <20060929.160807.28788865.davem@davemloft.net>
References: <1159565963.3741.23.camel@rh4>
	<20060929.154917.125894679.davem@davemloft.net>
	<451DA57F.60609@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55218
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932291AbWI2XIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 19:08:05 -0400
To: jeff@garzik.org
In-Reply-To: <451DA57F.60609@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 29 Sep 2006 19:00:15 -0400

> The patch and description provided no information about whether or not 
> it would be better to blacklist 8132 globally, as we have already done 
> with the 8131.

It absolutely was not vague, it gave an explicit description of what
the problem was, down to the transaction type being used by 5706 and
what the stated rules are in the PCI spec, and it also gave a clear
indication that the 5706 was in the wrong and that this was believed
to be a unique situation.
