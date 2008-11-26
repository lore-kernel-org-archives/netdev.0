From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/53] netns xfrm: add struct xfrm_policy::xp_net
Date: Tue, 25 Nov 2008 17:21:51 -0800 (PST)
Message-ID: <20081125.172151.190316003.davem@davemloft.net>
References: <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-13-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-14-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbYKZBVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:21:51 -0500
In-Reply-To: <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:26:46 +0300

> Again, to avoid complications with passing netns when not necessary.
> Again, ->xp_net is set-once field, once set it never changes.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
