From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: davinci_emac: make local function
 emac_poll_controller() static
Date: Wed, 20 Mar 2013 13:26:25 -0400 (EDT)
Message-ID: <20130320.132625.485717828800181562.davem@davemloft.net>
References: <CAPgLHd8=u1jepO+Z0HExYyyybaYtVcdqk0yhtmnLUieUhEGLTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	mugunthanvnm@ti.com, jiri@resnulli.us, agust@denx.de,
	bhutchings@solarflare.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695Ab3CTR02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:26:28 -0400
In-Reply-To: <CAPgLHd8=u1jepO+Z0HExYyyybaYtVcdqk0yhtmnLUieUhEGLTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 20 Mar 2013 23:01:45 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> emac_poll_controller() was not declared. It should be static.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
