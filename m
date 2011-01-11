From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-26] cxgb4vf: recover from failure in cxgb4vf_open()
Date: Tue, 11 Jan 2011 15:44:50 -0800 (PST)
Message-ID: <20110111.154450.199030883.davem@davemloft.net>
References: <1294783079-7481-1-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48784
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756382Ab1AKXoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 18:44:17 -0500
In-Reply-To: <1294783079-7481-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Tue, 11 Jan 2011 13:57:59 -0800

> If the Link Start fails in cxgb4vf_open(), we need to back out any state
> that we've built up ...
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied, thank you.
