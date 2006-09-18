From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] address: Allow address changes while device is
 administrative down
Date: Mon, 18 Sep 2006 00:13:14 -0700 (PDT)
Message-ID: <20060918.001314.75429185.davem@davemloft.net>
References: <20060901213957.138695086@lsx.localdomain>
	<20060901214015.026021813@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59859
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965519AbWIRHNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:13:16 -0400
To: tgraf@suug.ch
In-Reply-To: <20060901214015.026021813@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 01 Sep 2006 23:40:04 +0200

> Same behaviour as IPv4, using IFF_UP is a no-no anyway.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
