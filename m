From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] caif: precedence bug
Date: Thu, 22 Jul 2010 14:13:19 -0700 (PDT)
Message-ID: <20100722.141319.259998389.davem@davemloft.net>
References: <20100722111131.GB17585@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: SjurBraendeland@stericsson.com, sjur.brandeland@stericsson.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757481Ab0GVVNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:13:02 -0400
In-Reply-To: <20100722111131.GB17585@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 22 Jul 2010 13:11:31 +0200

> Negate has precedence over comparison so the original assert only
> checked that "rfml->fragment_size" was larger than 1 or 0.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
