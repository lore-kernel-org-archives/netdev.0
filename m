From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1b/2] tc: check for errors in gen_rate_estimator
 creation
Date: Tue, 25 Nov 2008 21:13:39 -0800 (PST)
Message-ID: <20081125.211339.50589914.davem@davemloft.net>
References: <20081125111423.0b953570@extreme>
	<492C4FC1.8080107@trash.net>
	<20081125112537.6cc3e5f2@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbYKZFNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:13:39 -0500
In-Reply-To: <20081125112537.6cc3e5f2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 25 Nov 2008 11:25:37 -0800

> The functions gen_new_estimator and gen_replace_estimator can return errors,
> but they were being ignored.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
