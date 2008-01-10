From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [ATM] Simplify /proc/net/atm/arp opening
Date: Thu, 10 Jan 2008 03:52:44 -0800 (PST)
Message-ID: <20080110.035244.250316041.davem@davemloft.net>
References: <20080110113044.GA16213@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, xemul@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43240
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753428AbYAJLwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:52:45 -0500
In-Reply-To: <20080110113044.GA16213@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 10 Jan 2008 14:30:44 +0300

> The iterator state->ns.neigh_sub_iter initialization is moved from
> arp_seq_open to clip_seq_start for convinience. This should not be a problem
> as the iterator will be used only after the seq_start callback.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.

