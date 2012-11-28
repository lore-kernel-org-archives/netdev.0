From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix miimon and arp_interval delayed work race
 conditions
Date: Wed, 28 Nov 2012 11:21:15 -0500 (EST)
Message-ID: <20121128.112115.1182089338474213708.davem@davemloft.net>
References: <1353759471-30323-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab2K1QVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:21:17 -0500
In-Reply-To: <1353759471-30323-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Bonding folks, please review.
