From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [NET] The world is not perfect patch.
Date: Wed, 21 May 2008 17:48:08 -0700 (PDT)
Message-ID: <20080521.174808.15066525.davem@davemloft.net>
References: <eb3ff54b0805200229r6fb2daa1w50aaffa9b130f89f@mail.gmail.com>
	<20080520.143321.97817925.davem@davemloft.net>
	<eb3ff54b0805210033m41e667dev6f7684b5495bdd6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48427
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934661AbYEVAsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 20:48:12 -0400
In-Reply-To: <eb3ff54b0805210033m41e667dev6f7684b5495bdd6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Wed, 21 May 2008 10:33:35 +0300

>   Unless there will be any objection here, I suggest consider the
> following patch which simply removes the code for the
> -DI_WISH_WORLD_WERE_PERFECT in the three methods which use it.
> 
> The compilation errors we get when using -DI_WISH_WORLD_WERE_PERFECT
> show that this code was not built and not used for really a long time.

Applied, thanks for following up on this Rami.
