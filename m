From: David Miller <davem@davemloft.net>
Subject: Re: updates to syncookies - timestamps not needed any more
 (freebsd)
Date: Fri, 12 Jul 2013 00:24:38 -0700 (PDT)
Message-ID: <20130712.002438.50315148803019035.davem@davemloft.net>
References: <20130708160421.GA9763@order.stressinduktion.org>
	<20130711.165726.2168148122875413191.davem@davemloft.net>
	<20130712014138.GD12611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757150Ab3GLHYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 03:24:42 -0400
In-Reply-To: <20130712014138.GD12611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 12 Jul 2013 03:41:38 +0200

> If I understood this thread[0] correctly, it seems Windows 8 might not
> enable TCP timestamps by default?

That is true, and my opinion of the situation took this into
consideration.
