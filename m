From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvtap: use prepare_to_wait/finish_wait to
 ensure mb
Date: Thu, 07 Jun 2012 13:19:40 -0700 (PDT)
Message-ID: <20120607.131940.1256581489594017198.davem@davemloft.net>
References: <1339058187-6619-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, zhiguo.hong@nsn.com,
	vikifang@juniper.net
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab2FGUTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:19:41 -0400
In-Reply-To: <1339058187-6619-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Thu,  7 Jun 2012 16:36:27 +0800

> instead of raw assignment to current->state
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Applied.
