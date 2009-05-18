From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dm9601: trivial comment fixes
Date: Sun, 17 May 2009 21:06:31 -0700 (PDT)
Message-ID: <20090517.210631.16692527.davem@davemloft.net>
References: <1242245393-14973-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbZEREGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:06:33 -0400
In-Reply-To: <1242245393-14973-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Wed, 13 May 2009 22:09:53 +0200

> The comments describing the rx/tx headers used a combination of zero-
> and 1-based indexing, leading to confusion. 
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied to net-next-2.6
