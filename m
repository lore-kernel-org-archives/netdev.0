From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: don't set connection request param size before
 copying data
Date: Mon, 10 Jan 2011 16:01:01 -0800 (PST)
Message-ID: <20110110.160101.84386472.davem@davemloft.net>
References: <1294702597.2125.74.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754467Ab1AKAA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:00:29 -0500
In-Reply-To: <1294702597.2125.74.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Mon, 10 Jan 2011 18:36:37 -0500

> The size field should not be set until after the data is successfully
> copied in.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

Applied, thanks.
