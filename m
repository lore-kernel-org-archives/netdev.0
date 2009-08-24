From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL 0/5] IEEE 802.15.4 updates
Date: Sun, 23 Aug 2009 19:19:46 -0700 (PDT)
Message-ID: <20090823.191946.66923222.davem@davemloft.net>
References: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	slapin@ossfans.org
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34544
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbZHXCTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 22:19:33 -0400
In-Reply-To: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Thu, 20 Aug 2009 20:13:02 +0400

> 
> The following changes since commit 886f9fe68310168358f55028a03553ae154dfeb6:
>   David S. Miller (1):
>         ppp_generic: Help GCC see that 'flen' is always initialized.
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next
> 
> Dmitry Eremin-Solenikov (5):
>       ieee802154: document the skb->cb usage clearly.
>       ieee802154: add a sysfs representation of WPAN master devices
>       fakehard: add binding to wpan-phy device
>       ieee802154: add support for channel pages from IEEE 802.15.4-2006
>       Drop ARPHRD_IEEE802154_PHY

Pulled, thanks a lot Dmitry.
