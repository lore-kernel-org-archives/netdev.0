From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 18/28] dsa: Add platform device support to Marvell switches
Date: Thu, 21 Jan 2016 16:05:42 -0500
Message-ID: <87wpr23aop.fsf@ketchup.mtl.sfl>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch> <1450875402-20740-19-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53986 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbcAUVMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 16:12:23 -0500
In-Reply-To: <1450875402-20740-19-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Just a single nitpick below.

Andrew Lunn <andrew@lunn.ch> writes:

<snip>

> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 02810a50825b..41472dc409ce 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -1,6 +1,7 @@
>  /*
>   * net/dsa/mv88e6060.c - Driver for Marvell 88e6060 switch chips
>   * Copyright (c) 2008-2009 Marvell Semiconductor
> + * Copywrite (c) 2015 Andrew Lunn <andrew@lunn.ch>

      Copyright ;-)
      
>   *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License as published by

<snip>

Thanks,
-v
