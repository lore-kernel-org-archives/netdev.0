From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: Use resource_size instead of private macro
Date: Wed, 09 Sep 2009 18:55:14 -0700 (PDT)
Message-ID: <20090909.185514.115840234.davem@davemloft.net>
References: <1252494464-4633-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754910AbZIJBy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:54:58 -0400
In-Reply-To: <1252494464-4633-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  9 Sep 2009 13:07:43 +0200

> The macro res_size in drivers/net/dm9000.c is a copy of resource_size in
> linux/ioport.h. Remove the function and use resource_size instead.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
