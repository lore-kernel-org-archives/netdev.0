From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] sky2: add GRO support
Date: Wed, 17 Jun 2009 18:52:41 -0700 (PDT)
Message-ID: <20090617.185241.89738275.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173140.297221387@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbZFRBwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:52:38 -0400
In-Reply-To: <20090617173140.297221387@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:39 -0700

> Add support for generic receive offload.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

This patch was hand edited in some way, as if you took hunks from a
*.rej file and directly copied them into the source yet did not remove
the leading spaces that are added to *.rej files by patch.

So there were a ton of "space before tab" errors emmited by GIT.  I
fixed these up for you.
