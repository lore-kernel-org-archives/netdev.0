From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 19:31:57 -0700 (PDT)
Message-ID: <20090727.193157.168527559.davem@davemloft.net>
References: <4A6D512A.1050504@gmail.com>
	<200907271106.02456.remi.denis-courmont@nokia.com>
	<4A6D60B4.1070601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbZG1Cbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 22:31:50 -0400
In-Reply-To: <4A6D60B4.1070601@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 27 Jul 2009 10:09:24 +0200

> I currently use gcc-3.4.6, and current net-next-2.6 doesnt compile
> for me (but linux-2.6 does compile properly so I just know this is
> already fixed upstream)

Eric, just FYI, I am not going to merge Linus's tree into
net-2.6 (and therefore not into net-next-2.6 either) unless
there is some conflict to resolve.

So if you need this build fix, please integrate it locally
by whatever means works best for you.
