From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/9] jme: PHY Power control for new chip
Date: Sun, 13 Feb 2011 20:44:08 -0800 (PST)
Message-ID: <20110213.204408.212392586.davem@davemloft.net>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
	<1297657662-30289-2-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arieslee@jmicron.com,
	devinchiu@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36870
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755145Ab1BNEnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 23:43:32 -0500
In-Reply-To: <1297657662-30289-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Mon, 14 Feb 2011 12:27:35 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> After main chip rev 5, the hardware support more power saving
> control registers.
> Some Non-Linux drivers might turn off the phy power with new
> interfaces, this patch makes it possible for Linux to turn it
> on again.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
