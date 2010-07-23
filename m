From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/7] be2net: supress printing error when mac
 query fails for VF
Date: Fri, 23 Jul 2010 12:44:07 -0700 (PDT)
Message-ID: <20100723.124407.115919872.davem@davemloft.net>
References: <20100723120008.GA24995@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751885Ab0GWTnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 15:43:51 -0400
In-Reply-To: <20100723120008.GA24995@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 23 Jul 2010 17:30:24 +0530

> When a virtual function driver in initialized, the network mac
> query command can fail. Skip display of error message in that case.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
