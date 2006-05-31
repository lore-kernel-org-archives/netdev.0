From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 00:49:53 -0700 (PDT)
Message-ID: <20060531.004953.91760903.davem@davemloft.net>
References: <20060530235525.A30563@openss7.org>
	<20060531.001027.60486156.davem@davemloft.net>
	<20060531014540.A1319@openss7.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11489
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S964851AbWEaHtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 03:49:33 -0400
To: bidulock@openss7.org
In-Reply-To: <20060531014540.A1319@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Date: Wed, 31 May 2006 01:45:40 -0600

> It might sound like I'm complaining, but I'm not.  The
> function works for me.  But from a purist point of view,
> the hash function is not as efficient as it could be and
> there is room for improvement.

For sure and there are plans afoot to move over to
dynamic table sizing and the Jenkins hash function.
