From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Correctly encode addresses when dumping mdb
 entries
Date: Wed, 19 Dec 2012 12:50:57 -0800 (PST)
Message-ID: <20121219.125057.104171680972167162.davem@davemloft.net>
References: <1355867648-17316-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443Ab2LSUu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:50:58 -0500
In-Reply-To: <1355867648-17316-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 18 Dec 2012 16:54:08 -0500

> When dumping mdb table, set the addresses the kernel returns
> based on the address protocol type.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.
