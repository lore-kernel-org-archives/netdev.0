From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] ipv4: hash net ptr into fragmentation
 bucket selection
Date: Wed, 25 Mar 2015 14:07:30 -0400 (EDT)
Message-ID: <20150325.140730.109377389694815085.davem@davemloft.net>
References: <119e03d3cffe2f7233f5132f6dce92b20bc55b07.1427299303.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, fbl@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942AbbCYSHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:07:32 -0400
In-Reply-To: <119e03d3cffe2f7233f5132f6dce92b20bc55b07.1427299303.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 25 Mar 2015 17:07:44 +0100

> As namespaces are sometimes used with overlapping ip address ranges,
> we should also use the namespace as input to the hash to select the ip
> fragmentation counter bucket.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
