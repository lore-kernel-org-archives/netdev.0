From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4 : igmp : Delete useless parameter in
 ip_mc_add1_src()
Date: Wed, 30 Nov 2011 23:17:26 -0500 (EST)
Message-ID: <20111130.231726.1253947573720018619.davem@davemloft.net>
References: <1322670065-13237-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab1LAER2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:17:28 -0500
In-Reply-To: <1322670065-13237-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Thu,  1 Dec 2011 00:21:04 +0800

> Need not to used 'delta' flag when add single-source to interface
> filter source list.
> 
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

Applied.
