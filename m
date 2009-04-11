From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity : fix compilation warning.
Date: Sat, 11 Apr 2009 01:44:31 -0700 (PDT)
Message-ID: <20090411.014431.99957231.davem@davemloft.net>
References: <1239276837-17085-1-git-send-email-rseguier@e-teleport.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: rseguier@e-teleport.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754318AbZDKIol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 04:44:41 -0400
In-Reply-To: <1239276837-17085-1-git-send-email-rseguier@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Seguier Regis <rseguier@e-teleport.net>
Date: Thu,  9 Apr 2009 11:33:57 +0000

> Fix this warning:
> drivers/net/via-velocity.c:1924: warning: passing argument 2 of 'request_irq' from incompatible pointer type
> 
> Signed-off-by: Seguier Regis <rseguier@e-teleport.net>

Applied.
