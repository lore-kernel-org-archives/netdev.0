From: David Miller <davem@davemloft.net>
Subject: Re: Add missing braces in bnx2x:bnx2x_link_initialize
Date: Thu, 05 Sep 2013 14:21:17 -0400 (EDT)
Message-ID: <20130905.142117.1916319107625842387.davem@davemloft.net>
References: <20130905034658.GA12717@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab3IESVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:21:19 -0400
In-Reply-To: <20130905034658.GA12717@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David, I'm going to apply your missing braces patches, but I'm really irritated
that I've told you at least 5 times to put proper subsystem prefixes into
your subject lines.

For this I'd use "bnx2x: ", for the TCP patch I'd use "tcp: " and for the
CAIF change I'd use "caif: "

Please get into the habit of doing this, or I'm going to push back on you
to correct this instead of fixing it up automatically for you every time,
since the latter really is not scalable.
