From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] be2net: change to call pmac_del only if
 necessary
Date: Fri, 23 Jul 2010 12:43:08 -0700 (PDT)
Message-ID: <20100723.124308.112611570.davem@davemloft.net>
References: <20100723114850.GA24854@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754515Ab0GWTmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 15:42:51 -0400
In-Reply-To: <20100723114850.GA24854@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 23 Jul 2010 17:19:04 +0530

> If a mac address has not been configured for a VF,
> there is no need to call be_cmd_pmac_del.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
