From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH] mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
Date: Mon, 02 May 2016 02:48:01 +0200
Message-ID: <5726A3C1.5070009@denx.de>
References: <1461892155-10524-1-git-send-email-marex@denx.de> <20160501.194945.1926401275113473949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de,
	dinguyen@opensource.altera.com, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:33494 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbcEBAsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 20:48:05 -0400
In-Reply-To: <20160501.194945.1926401275113473949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2016 01:49 AM, David Miller wrote:
> 
> Please respin this with the checkpatch errors fixed.

Done and sent.

> I don't have any opinion about the conditional parenthesis, so
> don't worry about that.
> 
OK

Thanks!

-- 
Best regards,
Marek Vasut
