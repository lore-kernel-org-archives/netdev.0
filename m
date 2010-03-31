From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: ethtool RXHASH flag
Date: Tue, 30 Mar 2010 23:52:22 -0700 (PDT)
Message-ID: <20100330.235222.15020149.davem@davemloft.net>
References: <20100328154448.701c89ee@nehalam>
	<20100329174727.4654e19c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755497Ab0CaGwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:52:20 -0400
In-Reply-To: <20100329174727.4654e19c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 29 Mar 2010 17:47:27 -0700

> This adds ethtool and device feature flag to allow control
> of receive hashing offload.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> Supersedes earlier patch, decided to call it RXHASH not RSS since
> we don't care about other vendors acronyms

Ah, now I understand, ignore my other email.

Applied, thanks everyone.
