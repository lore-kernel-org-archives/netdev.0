From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Return hna count on local buffer fill
Date: Mon, 20 Dec 2010 10:32:12 -0800 (PST)
Message-ID: <20101220.103212.71113722.davem@davemloft.net>
References: <1292786890-17755-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932742Ab0LTSbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 13:31:43 -0500
In-Reply-To: <1292786890-17755-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Sun, 19 Dec 2010 20:28:10 +0100

> hna_local_fill_buffer must return the number of added hna entries and
> not the last checked hash bucket.
> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>

Applied.
