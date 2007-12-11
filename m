From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work (v2)
Date: Tue, 11 Dec 2007 02:27:04 -0800 (PST)
Message-ID: <20071211.022704.128575269.davem@davemloft.net>
References: <20071211074504.GA8334@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbXLKK1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:27:05 -0500
In-Reply-To: <20071211074504.GA8334@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 11 Dec 2007 10:45:04 +0300

> Changes from v1:
> - renamed fields according to Daniel Lezcano suggestion

More changes from v1:
- Forgot to include net/netns/unix.h in the patch

Please fix this :-)
