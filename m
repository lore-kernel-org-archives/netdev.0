From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Fri, 31 Oct 2008 00:07:30 -0700 (PDT)
Message-ID: <20081031.000730.40575543.davem@davemloft.net>
References: <20081028.155817.216873568.davem@davemloft.net>
	<1225249103.7276.56.camel@sebastian.kern.oss.ntt.co.jp>
	<20081028.220647.161635128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60781
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbYJaHH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:07:56 -0400
In-Reply-To: <20081028.220647.161635128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 28 Oct 2008 22:06:47 -0700 (PDT)

> Good points, I'll think about this some more.

Fernando, you're right (of course :), so I've applied your original
patch.

Thanks!
