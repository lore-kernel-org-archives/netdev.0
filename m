From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2 v2] rhashtable rehashing fixes
Date: Wed, 22 Apr 2015 14:21:44 -0400 (EDT)
Message-ID: <20150422.142144.1668540092291085139.davem@davemloft.net>
References: <cover.1429688383.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbbDVSVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 14:21:47 -0400
In-Reply-To: <cover.1429688383.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Apr 2015 09:41:44 +0200

> Some rhashtable rehashing bugs found while testing with the
> next rhashtable self-test queued up for the next devel cycle:
> 
> https://github.com/tgraf/net-next/commits/rht
> 
> v2:
>  - Moved schedule_work() call into rhashtable_insert_rehash()

Series applied, thanks guys.
