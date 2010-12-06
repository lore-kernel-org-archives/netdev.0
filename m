From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emaclite: Omit private ndo_get_stats function
Date: Mon, 06 Dec 2010 13:25:17 -0800 (PST)
Message-ID: <20101206.132517.59683851.davem@davemloft.net>
References: <1291310439-5813-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753530Ab0LFVYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:24:49 -0500
In-Reply-To: <1291310439-5813-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  2 Dec 2010 18:20:39 +0100

> xemaclite_get_stats() just returns dev->stats so we can leave it out
> alltogether and let dev_get_stats() do the job.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
