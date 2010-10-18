From: David Miller <davem@davemloft.net>
Subject: Re: [patch] gianfar: fix double lock typo
Date: Mon, 18 Oct 2010 01:55:28 -0700 (PDT)
Message-ID: <20101018.015528.71129771.davem@davemloft.net>
References: <20101013191954.GE6060@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sandeep.Kumar@freescale.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42844
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753922Ab0JRIzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 04:55:06 -0400
In-Reply-To: <20101013191954.GE6060@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 13 Oct 2010 21:19:55 +0200

> This should be a _restore() instead of a _save().
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Good find, applied, thanks!
