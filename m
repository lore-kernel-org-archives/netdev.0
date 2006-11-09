From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [NET] rules: Share common attribute validation
 policy
Date: Thu, 09 Nov 2006 15:23:00 -0800 (PST)
Message-ID: <20061109.152300.14991155.davem@davemloft.net>
References: <20061109112735.577771022@lsx.localdomain>
	<20061109113245.978740794@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54433
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424256AbWKIXWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:22:51 -0500
To: tgraf@suug.ch
In-Reply-To: <20061109113245.978740794@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 09 Nov 2006 12:27:40 +0100

> Move the attribute policy for the non-specific attributes into
> net/fib_rules.h and include it in the respective protocols.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks nice, applied, thanks.
