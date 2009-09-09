From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: Use resource_size instead of private function
Date: Wed, 09 Sep 2009 01:41:39 -0700 (PDT)
Message-ID: <20090909.014139.124057362.davem@davemloft.net>
References: <1252481150-12166-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbZIIIup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 04:50:45 -0400
In-Reply-To: <1252481150-12166-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  9 Sep 2009 09:25:50 +0200

> The function res_size in drivers/net/niu.c is a copy of resource_size in
> linux/ioport.h. Remove the function and use resource_size instead.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Patch applied, thank you.
