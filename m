From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3][IPV6]: create route6 proc init-fini functions
Date: Sat, 08 Dec 2007 00:13:46 -0800 (PST)
Message-ID: <20071208.001346.69897017.davem@davemloft.net>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071207131810.854735805@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45068
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753768AbXLHINr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:13:47 -0500
In-Reply-To: <20071207131810.854735805@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 07 Dec 2007 14:13:26 +0100

> Make the proc creation/destruction to be a separate function. That allows to
> remove the #ifdef CONFIG_PROC_FS in the init/fini function and make them more
> readable.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
