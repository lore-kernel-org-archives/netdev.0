From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL 0/5] IEEE 802.15.4 last-minute fixes.
Date: Mon, 03 Aug 2009 19:35:46 -0700 (PDT)
Message-ID: <20090803.193546.102476162.davem@davemloft.net>
References: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbZHDCfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 22:35:37 -0400
In-Reply-To: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Tue,  4 Aug 2009 02:51:37 +0400

> Please pull several minor fixes for the IEEE 802.15.4 stack.

No.

Removing an unused macro IS NOT A BUG FIX!

Marking a variable 'const' IS NOT A BUG FIX!

And therefore it is absolutely, positively, not appropriate for
2.6.31-rcX at this time.

Do not send any more patches to me until you can sort your
changes properly.

I'm tossing this entire series.
