From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] [NET]: Turn nfmark into generic mark
Date: Thu, 09 Nov 2006 15:19:27 -0800 (PST)
Message-ID: <20061109.151927.08147387.davem@davemloft.net>
References: <20061109112735.577771022@lsx.localdomain>
	<20061109113245.439512828@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27540
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424247AbWKIXTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:19:19 -0500
To: tgraf@suug.ch
In-Reply-To: <20061109113245.439512828@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 09 Nov 2006 12:27:36 +0100

> nfmark is being used in various subsystems and has become
> the defacto mark field for all kinds of packets. Therefore
> it makes sense to rename it to `mark' and remove the
> dependency on CONFIG_NETFILTER.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
