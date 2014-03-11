From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: force cast of IP address in options
Date: Tue, 11 Mar 2014 16:37:54 -0400 (EDT)
Message-ID: <20140311.163754.1376810404707141660.davem@davemloft.net>
References: <20140310094838.6d286cb2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755623AbaCKUh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:37:56 -0400
In-Reply-To: <20140310094838.6d286cb2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Mar 2014 09:48:38 -0700

> The option code is taking IP address and putting it into a generic
> container. Force cast to silence sparse warnings.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
