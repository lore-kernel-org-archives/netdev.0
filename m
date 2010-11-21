From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netns: let net_generic take pointer-to-const args
Date: Sun, 21 Nov 2010 10:05:29 -0800 (PST)
Message-ID: <20101121.100529.183060912.davem@davemloft.net>
References: <alpine.LNX.2.01.1011210506110.9636@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754645Ab0KUSFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 13:05:04 -0500
In-Reply-To: <alpine.LNX.2.01.1011210506110.9636@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Sun, 21 Nov 2010 05:07:21 +0100 (CET)

> netns: let net_generic take pointer-to-const args
> 
> This commit is same in nature as v2.6.37-rc1-755-g3654654; the network
> namespace itself is not modified when calling net_generic, so the
> parameter can be const.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Applied.
