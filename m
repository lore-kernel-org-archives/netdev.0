From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: precedence confusion !x & y
Date: Fri, 08 Aug 2008 16:20:47 -0700 (PDT)
Message-ID: <20080808.162047.163238935.davem@davemloft.net>
References: <489D1CA3.80504@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanivr@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752916AbYHHXUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 19:20:46 -0400
In-Reply-To: <489D1CA3.80504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roel kluin <roel.kluin@gmail.com>
Date: Sat, 09 Aug 2008 00:27:15 -0400

> ! has a higher precedence than &
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

This is already fixed in Linus's tree.
