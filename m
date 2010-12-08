From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] via-velocity: set sleep speed to 10Mbps for
 powersaving.
Date: Wed, 08 Dec 2010 12:56:57 -0800 (PST)
Message-ID: <20101208.125657.212691053.davem@davemloft.net>
References: <AANLkTi==2E1VxbXatjEN7hORfPbxmiSTbD6SwqH5JGEu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	DavidLv@viatech.com.cn, ShirleyHu@viatech.com.cn,
	AndersMa@viatech.com.cn
To: davidlv.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41312
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932070Ab0LHU43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:56:29 -0500
In-Reply-To: <AANLkTi==2E1VxbXatjEN7hORfPbxmiSTbD6SwqH5JGEu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lv <davidlv.linux@gmail.com>
Date: Wed, 8 Dec 2010 12:10:53 +0800

> I am sending this patch for setting speed to 10Mbps when entering into
> sleep mode.
> It is for power saving.
> Thanks!
> 
> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
 ...
> +	velocity_set_int_opt((int *) &opts->sleep_speed_10m, sleep_speed_10M[index],
> +		SLEEP_SPEED_DISABLE, SLEEP_SPEED_ENABLE, SLEEP_SPEED_DEF, "Sleep
> Speed Forced 10M", devname);
 ...

Same problem here, you email client corrupted the patch,
please fix this and resubmit.

Thanks.
