From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] (resubmit) Use list_head-s in inetpeer.c
Date: Mon, 12 Nov 2007 21:27:38 -0800 (PST)
Message-ID: <20071112.212738.52184377.davem@davemloft.net>
References: <473862B1.206@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33430
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752256AbXKMF1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:27:38 -0500
In-Reply-To: <473862B1.206@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 12 Nov 2007 17:26:57 +0300

> The inetpeer.c tracks the LRU list of inet_perr-s, but makes
> it by hands. Use the list_head-s for this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
