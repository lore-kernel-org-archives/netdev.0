From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove /proc/net/stat/*_arp_cache upon module removal
Date: Mon, 05 Nov 2007 21:28:30 -0800 (PST)
Message-ID: <20071105.212830.155577008.davem@davemloft.net>
References: <20071101135235.GB8639@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37256
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbXKFF2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 00:28:31 -0500
In-Reply-To: <20071101135235.GB8639@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Thu, 1 Nov 2007 16:52:35 +0300

> neigh_table_init_no_netlink() creates them, but they aren't removed anywhere.
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied, thanks Alexey.
