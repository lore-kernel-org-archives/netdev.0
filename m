From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] caif: remove unneeded variable from caif_net_open()
Date: Wed, 02 Jun 2010 05:16:43 -0700 (PDT)
Message-ID: <20100602.051643.128602911.davem@davemloft.net>
References: <20100601070855.GD5483@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52575
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751540Ab0FBMQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:16:33 -0400
In-Reply-To: <20100601070855.GD5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 1 Jun 2010 09:08:55 +0200

> We don't use the "ser" variable so I've removed it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
