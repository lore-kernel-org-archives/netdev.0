From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7 net-2.6.26] [TIPC]: Use correct bitmask when
 setting version
Date: Thu, 06 Mar 2008 15:07:49 -0800 (PST)
Message-ID: <20080306.150749.230704528.davem@davemloft.net>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
	<1204839269-30593-6-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757928AbYCFXHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:07:49 -0500
In-Reply-To: <1204839269-30593-6-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu,  6 Mar 2008 16:34:27 -0500

> This patch ensures that the 3-bit version field of the TIPC
> message header is masked correctly when written into a message.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
