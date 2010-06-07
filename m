From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] htb: remove two unnecessary assignments
Date: Mon, 07 Jun 2010 01:21:06 -0700 (PDT)
Message-ID: <20100607.012106.124076824.davem@davemloft.net>
References: <1275651213-3343-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932445Ab0FGIU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:20:56 -0400
In-Reply-To: <1275651213-3343-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri,  4 Jun 2010 19:33:33 +0800

> remove two unnecessary assignments
> 
> we don't need to assign NULL when initialize structure objects.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
