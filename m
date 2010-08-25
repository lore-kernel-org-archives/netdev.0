From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/3] be2net: remove a BUG_ON in be_cmds.c
Date: Wed, 25 Aug 2010 14:23:17 -0700 (PDT)
Message-ID: <20100825.142317.48523084.davem@davemloft.net>
References: <20100825103109.GA15581@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754254Ab0HYVXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 17:23:01 -0400
In-Reply-To: <20100825103109.GA15581@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 25 Aug 2010 16:01:20 +0530

> Async notifications other than link status are possible in certain
> configurations. Remove the BUG_ON in the mcc completion processing path.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
