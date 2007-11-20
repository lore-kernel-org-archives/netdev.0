From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6 net-2.6.25][RAW] Consolidate proto->unhash callback
Date: Mon, 19 Nov 2007 22:38:05 -0800 (PST)
Message-ID: <20071119.223805.110427744.davem@davemloft.net>
References: <473DA612.3040906@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755145AbXKTGiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:38:06 -0500
In-Reply-To: <473DA612.3040906@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 16 Nov 2007 17:15:46 +0300

> Same as the ->hash one, this is easily consolidated.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
