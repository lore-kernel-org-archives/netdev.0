From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/atm/Kconfig: remove dead ATM_TNETA1570
 option
Date: Tue, 19 Dec 2006 19:35:18 -0800 (PST)
Message-ID: <20061219.193518.97293486.davem@davemloft.net>
References: <20061219041300.GD6993@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37097
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964840AbWLTDfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 22:35:20 -0500
To: bunk@stusta.de
In-Reply-To: <20061219041300.GD6993@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 19 Dec 2006 05:13:00 +0100

> This patch removes the unconverted ATM_TNETA1570 option that also lacks 
> any code in the kernel.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
