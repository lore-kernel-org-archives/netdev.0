From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] Fix warning, issue and give some enhancements
Date: Mon, 15 Aug 2016 13:50:01 -0700 (PDT)
Message-ID: <20160815.135001.2129164870243111346.davem@davemloft.net>
References: <1471283487-24113-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323AbcHOUuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 16:50:02 -0400
In-Reply-To: <1471283487-24113-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>
Date: Tue, 16 Aug 2016 01:51:21 +0800

> This patch set fixes the following warning and issues and gives some 
> enhancements about RX path handling.
> 
> v1 -> v2: fix message typos and add coverletter

Please do not mix bug fixes and changes which are not bug fixes.

Submit bug fixes as a series targetting 'net'.

Submit the rest targetting 'net-next'.

Thanks.
