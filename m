From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-02-23
Date: Tue, 24 Feb 2009 23:53:17 -0800 (PST)
Message-ID: <20090224.235317.10940015.davem@davemloft.net>
References: <20090223192617.GA3553@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54866
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757426AbZBYHxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:53:39 -0500
In-Reply-To: <20090223192617.GA3553@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 23 Feb 2009 14:26:17 -0500

> Here are a couple of fixes, one for an oops and one for a warning.  Also
> included is a PCI ID addition.  These are intended for 2.6.29.

Pulled, thanks John.

> P.S.  This causes some conflicts with -next.  The ath9k conflict is
> simple.  The orinoco conflict involves moving some code from orinoco.c
> to orinoco/main.c in -next (where orinoco.c no longer exists).  I have
> included a "merge-test" branch in the wireless-next-2.6 tree to provide
> and example for the merge when you get to it.

Ok, I'll take care of that now, thanks John.
