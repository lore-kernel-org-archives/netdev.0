From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Mon, 26 Oct 2015 18:14:41 -0700 (PDT)
Message-ID: <20151026.181441.2284144627314361128.davem@davemloft.net>
References: <1445625487-16313-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jiri@resnulli.us, andrew@lunn.ch, linux@roeck-us.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbbJ0A6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 20:58:04 -0400
In-Reply-To: <1445625487-16313-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 23 Oct 2015 11:38:07 -0700

> Add support for the FDB add, delete, and dump operations. The add and
> delete operations are implemented using directed ARL operations using
> the specified MAC address and consist in a read operation, write and
> readback operation.
> 
> The dump operation consists in using the ARL search and software
> filtering entries which are not for the desired port.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
