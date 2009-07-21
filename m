From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH][be2net] Add GRO support to the be2net
 driver. LRO is not supported anymore.
Date: Tue, 21 Jul 2009 12:36:35 -0700 (PDT)
Message-ID: <20090721.123635.76413778.davem@davemloft.net>
References: <20090721120701.GA7570@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751973AbZGUTg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 15:36:29 -0400
In-Reply-To: <20090721120701.GA7570@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Tue, 21 Jul 2009 17:37:11 +0530

> 
> This patch removes support for INET_LRO and switches over to GRO.
>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, thanks a lot for doing this work.
