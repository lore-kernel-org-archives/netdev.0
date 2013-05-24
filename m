From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: refactor HW workarounds in be_xmit()
Date: Thu, 23 May 2013 18:58:02 -0700 (PDT)
Message-ID: <20130523.185802.576781890781097805.davem@davemloft.net>
References: <1369299895-23388-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759746Ab3EXB6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 21:58:03 -0400
In-Reply-To: <1369299895-23388-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 23 May 2013 14:34:55 +0530

> Refactor all TX HW workarounds into a separate routine called
> be_xmit_workarounds().
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
