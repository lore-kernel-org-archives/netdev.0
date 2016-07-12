From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] net: ethoc: Error path and transmit fixes
Date: Mon, 11 Jul 2016 19:47:22 -0700 (PDT)
Message-ID: <20160711.194722.1606384510669735240.davem@davemloft.net>
References: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcmvbkbc@gmail.com,
	colin.king@canonical.com, tklauser@distanz.ch,
	thierry.reding@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbcGLCrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 22:47:23 -0400
In-Reply-To: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 11 Jul 2016 16:35:53 -0700

> I don't have access to any other platform using an ethoc interface so
> it could be good to some testing on Xtensa for instance.

So I'll wait until someone does such testing before applying this
series.
