From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: implement SGMII-based in-band link state
 signaling
Date: Fri, 03 Apr 2015 15:06:40 -0400 (EDT)
Message-ID: <20150403.150640.1127683098760744259.davem@davemloft.net>
References: <20150402.205131.1699226515102250937.davem@davemloft.net>
	<551DE6F9.9020903@gmail.com>
	<20150403.150410.1238626255318297531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stsp@list.ru, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150403.150410.1238626255318297531.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 03 Apr 2015 15:04:10 -0400 (EDT)

> Ok I'll apply this mvneta patch to net-next then, thanks.

Nevermind I just saw in my patchwork queue that there is a v3
of this change set that adds some adjustments to the fixed
PHY interfaces.

I think I'll apply that series instead of this patch.
