From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/isdn/hardware/mISDN: change type of
 hfc_jiffies to unsigned long
Date: Sun, 15 Feb 2009 23:40:07 -0800 (PST)
Message-ID: <20090215.234007.25283952.davem@davemloft.net>
References: <20090214230701.21991.75646.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58337
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755778AbZBPHkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 02:40:24 -0500
In-Reply-To: <20090214230701.21991.75646.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sun, 15 Feb 2009 00:10:33 +0100

> Jiffies are unsigned long, make sure we fit in jiffies store variable
> on archs with bits per long > 32.
> 
> Patch suggested by Jiri Slaby.
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Also applied, thank you.
