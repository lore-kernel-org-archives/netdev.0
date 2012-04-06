From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 00/39] net_device.{base_addr, irq} removal
 update
Date: Fri, 06 Apr 2012 06:26:26 -0400 (EDT)
Message-ID: <20120406.062626.578458566949440559.davem@davemloft.net>
References: <1333704408.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com, andy@greyhouse.net,
	chris.snook@gmail.com, venza@brownhat.org, DavidLv@viatech.com.cn,
	grantgrundler@gmail.com, ionut@badula.org, jcliburn@gmail.com,
	jdmason@kudzu.us, mason@myri.com, mchan@broadcom.com,
	stas.yakovlev@gmail.com, steve.glendinning@smsc.com,
	thockin@hockin.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab2DFK3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 06:29:02 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri,  6 Apr 2012 12:06:14 +0200

> If there are no further changes, I'll rebase and send a single pull request
> for the series including Grant's Acked-by once he says it is ok.

Besides the request_irq() return value test issues, this series
seems fine to me.
