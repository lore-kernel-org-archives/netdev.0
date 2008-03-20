From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 (spin 2) resend] TCP_DEFER_ACCEPT updates - process
 as established
Date: Thu, 20 Mar 2008 16:18:37 -0700 (PDT)
Message-ID: <20080320.161837.232769077.davem@davemloft.net>
References: <1206053493.13044.14.camel@tng>
	<1206053758.13044.24.camel@tng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcmanus@ducksong.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40556
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759193AbYCTXSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 19:18:25 -0400
In-Reply-To: <1206053758.13044.24.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This looks wrong.  Are you sure you're resending the
correct patch?

The most uptodate version was "spin 3" in which you
incorporated coding style and checkpatch.pl fixes
as recommended by Ilpo.
