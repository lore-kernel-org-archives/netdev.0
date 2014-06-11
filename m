From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ceph: remove bogus extern
Date: Wed, 11 Jun 2014 15:40:30 -0700 (PDT)
Message-ID: <20140611.154030.2284694286671326441.davem@davemloft.net>
References: <20140610203013.6a5e5904@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sage@inktank.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbaFKWkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:40:31 -0400
In-Reply-To: <20140610203013.6a5e5904@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 10 Jun 2014 20:30:13 -0700

> Sparse complained about this bogus extern on definition of
> a function.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
