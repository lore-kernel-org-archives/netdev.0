From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Fri, 28 Mar 2008 15:57:51 -0700 (PDT)
Message-ID: <20080328.155751.06268684.davem@davemloft.net>
References: <200803280036.59311.vda.linux@googlemail.com>
	<20080327.175212.119805454.davem@davemloft.net>
	<200803282334.29975.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	acme@redhat.com
To: vda.linux@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754227AbYC1W55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 18:57:57 -0400
In-Reply-To: <200803282334.29975.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Fri, 28 Mar 2008 23:34:29 +0100

> Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>

Applied, thanks!
