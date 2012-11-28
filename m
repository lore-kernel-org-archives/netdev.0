From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix race condition in
 bonding_store_slaves_active
Date: Wed, 28 Nov 2012 11:21:35 -0500 (EST)
Message-ID: <20121128.112135.282569155458535958.davem@davemloft.net>
References: <1353759595-30452-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814Ab2K1QVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:21:37 -0500
In-Reply-To: <1353759595-30452-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some bonding developer reviews would be appreciated.
