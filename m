From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SiS190/191 half-duplex initialization fix
Date: Wed, 17 Feb 2010 13:39:10 -0800 (PST)
Message-ID: <20100217.133910.143553318.davem@davemloft.net>
References: <1266434938-11199-1-git-send-email-birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: birrachiara@tin.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757187Ab0BQViy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:38:54 -0500
In-Reply-To: <1266434938-11199-1-git-send-email-birrachiara@tin.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Riccardo Ghetta <birrachiara@tin.it>
Date: Wed, 17 Feb 2010 20:28:58 +0100

> Adds half-duplex specific setup code (taken from SiS own GPL driver).
> Without those, half-duplex connections are very unreliable, often
> working on small transfers and failing after a while.
> 
> Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>

Applied.
