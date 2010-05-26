From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: increase POST timeout for EEH recovery
Date: Wed, 26 May 2010 00:33:52 -0700 (PDT)
Message-ID: <20100526.003352.183036046.davem@davemloft.net>
References: <20100526070048.GA2312@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751095Ab0EZHdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 03:33:42 -0400
In-Reply-To: <20100526070048.GA2312@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 26 May 2010 12:30:48 +0530

> Sometimes BE requires longer time for POST completion after an EEH reset.
> Increasing the timeout value accordingly.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied, thanks.
