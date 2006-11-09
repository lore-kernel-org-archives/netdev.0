From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] [NET] rules: Add support to invert selectors
Date: Thu, 09 Nov 2006 15:23:37 -0800 (PST)
Message-ID: <20061109.152337.99829269.davem@davemloft.net>
References: <20061109112735.577771022@lsx.localdomain>
	<20061109113246.170519079@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55457
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424241AbWKIXX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:23:29 -0500
To: tgraf@suug.ch
In-Reply-To: <20061109113246.170519079@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 09 Nov 2006 12:27:41 +0100

> Introduces a new flag FIB_RULE_INVERT causing rules to apply
> if the specified selector doesn't match.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied, thanks.
