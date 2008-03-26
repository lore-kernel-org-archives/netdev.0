From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [TIPC]: Cosmetic cleanup of TIPC polling
 logic
Date: Wed, 26 Mar 2008 16:48:38 -0700 (PDT)
Message-ID: <20080326.164838.27186788.davem@davemloft.net>
References: <1206565359-14538-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751878AbYCZXsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 19:48:38 -0400
In-Reply-To: <1206565359-14538-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Wed, 26 Mar 2008 17:02:39 -0400

> This patch eliminates an unnecessary poll-related routine
> by merging it into TIPC's main polling routine, and updates
> the comments associated with this code.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied, thanks.
