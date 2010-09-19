From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bna: off by one
Date: Sun, 19 Sep 2010 11:26:02 -0700 (PDT)
Message-ID: <20100919.112602.183060281.davem@davemloft.net>
References: <20100918234144.GB6236@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, ddutt@brocade.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755037Ab0ISSZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 14:25:43 -0400
In-Reply-To: <20100918234144.GB6236@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 19 Sep 2010 01:41:44 +0200

> The mod->mbhdlr[] array has BFI_MC_MAX elements.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
