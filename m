From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 03/03] [PATCH] vxlan: fix crash on module removal
Date: Mon, 10 Jun 2013 14:18:16 -0700 (PDT)
Message-ID: <20130610.141816.1546753299816672552.davem@davemloft.net>
References: <20130610131315.384c5b61@nehalam.linuxnetplumber.net>
	<20130610.140114.1116004856133608655.davem@redhat.com>
	<20130610.141421.1570141372448161465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab3FJVSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 17:18:17 -0400
In-Reply-To: <20130610.141421.1570141372448161465.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 10 Jun 2013 14:14:21 -0700 (PDT)

> Actually, this doesn't even compile.

One last thing, no compile testing means no functional testing was
done on these patches in the environment in which they were meant to
be applied.
