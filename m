From: David Miller <davem@davemloft.net>
Subject: Re: iprule: add oif classification support
Date: Thu, 03 Dec 2009 15:49:57 -0800 (PST)
Message-ID: <20091203.154957.131929849.davem@davemloft.net>
References: <4B14082E.208@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754495AbZLCXtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:49:50 -0500
In-Reply-To: <4B14082E.208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 30 Nov 2009 19:00:14 +0100

> This patch contains iproute support for iprule oif classification
> for the send-to-self RFC I just sent out.

Patrick, you need to submit a new version of this patch with
the FIB_RULE_* macro fixed, just like the kernel version got
fixed.
