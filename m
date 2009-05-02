From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: Fix tcp_prequeue() to get correct rto_min
 value
Date: Sat, 02 May 2009 09:56:57 -0700 (PDT)
Message-ID: <20090502.095657.32839668.davem@davemloft.net>
References: <20090502075133.GC13165@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: satoru.satoh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58625
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754405AbZEBQ5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 12:57:02 -0400
In-Reply-To: <20090502075133.GC13165@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satoru SATOH <satoru.satoh@gmail.com>
Date: Sat, 2 May 2009 16:51:33 +0900

> This patch depends on the previous patch, makes tcp_prequeue() uses the
> correct tcp rto_min value returns from tcp_rto_min().
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

These two patches logically belong together, please combine
them and resubmit.

Thanks!
