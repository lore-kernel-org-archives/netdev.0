From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] ipv6: hash net ptr into fragmentation
 bucket selection
Date: Wed, 25 Mar 2015 14:07:36 -0400 (EDT)
Message-ID: <20150325.140736.666869681042648041.davem@davemloft.net>
References: <119e03d3cffe2f7233f5132f6dce92b20bc55b07.1427299303.git.hannes@stressinduktion.org>
	<119e03d3cffe2f7233f5132f6dce92b20bc55b07.1427299303.git.hannes@stressinduktion.org>
	<5e251a7cd84525368e820d961db0fd0ff66323c8.1427299303.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, fbl@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942AbbCYSHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:07:38 -0400
In-Reply-To: <5e251a7cd84525368e820d961db0fd0ff66323c8.1427299303.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 25 Mar 2015 17:07:45 +0100

> As namespaces are sometimes used with overlapping ip address ranges,
> we should also use the namespace as input to the hash to select the ip
> fragmentation counter bucket.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
