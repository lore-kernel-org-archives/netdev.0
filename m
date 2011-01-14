From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7 v2] GRETH: fixed skb buffer memory leak on frame
 errors
Date: Fri, 14 Jan 2011 12:46:45 -0800 (PST)
Message-ID: <20110114.124645.258888087.davem@davemloft.net>
References: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
	<1295010163-2585-4-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080Ab1ANUqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 15:46:12 -0500
In-Reply-To: <1295010163-2585-4-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Fri, 14 Jan 2011 14:02:40 +0100

> A new SKB buffer should not be allocated when the old SKB is reused.
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

Applied.
