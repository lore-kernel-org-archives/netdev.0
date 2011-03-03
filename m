From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Thu, 03 Mar 2011 14:01:34 -0800 (PST)
Message-ID: <20110303.140134.241924015.davem@davemloft.net>
References: <4D6EA33D.70801@gmail.com>
	<20110303.134256.68141248.davem@davemloft.net>
	<4D700D66.5090300@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, florian@openwrt.org, netdev@vger.kernel.org
To: mr.nuke.me@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33556
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758251Ab1CCWA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 17:00:57 -0500
In-Reply-To: <4D700D66.5090300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Still wrong, the patch needs to be "-p1" not "-p0" rooted.
