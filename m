From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/44] [XFRM] STATE: Add source address list.
Date: Wed, 23 Aug 2006 19:08:59 -0700 (PDT)
Message-ID: <20060823.190859.89280531.davem@davemloft.net>
References: <11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
	<20060823.175436.28791154.davem@davemloft.net>
	<44ECFEB3.3030201@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9857
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030190AbWHXCI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:08:57 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44ECFEB3.3030201@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Thu, 24 Aug 2006 10:19:47 +0900

> As you may already find out the resolution will not be so hard
> since this it is doing the same thing as destination hash about
> XFRM list.

Correct.  I also do not think it will be very difficult.
