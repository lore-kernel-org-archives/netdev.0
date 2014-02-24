From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [net-next v3 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 24 Feb 2014 13:33:48 +0100
Message-ID: <1393245228.4190.14.camel@jlt4.sipsolutions.net>
References: <1393244920-15903-1-git-send-email-sw@simonwunderlich.de>
	 <1393244920-15903-4-git-send-email-sw@simonwunderlich.de>
	 (sfid-20140224_132903_316161_47795452)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de
To: Simon Wunderlich <sw@simonwunderlich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49626 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaBXMdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 07:33:54 -0500
In-Reply-To: <1393244920-15903-4-git-send-email-sw@simonwunderlich.de> (sfid-20140224_132903_316161_47795452)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-24 at 13:28 +0100, Simon Wunderlich wrote:
> MPLS labels may contain traffic control information, which should be
> evaluated and used by the wireless subsystem if present.
> 
> Also check for IEEE 802.21 which is always network control traffic.

Fine with me. I guess this should go through net-next due to the
dependencies on patches 1 and 2.

> Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
> Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes
