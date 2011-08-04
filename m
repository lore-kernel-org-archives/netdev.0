From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] slip: cleanup statistics generation
Date: Wed, 03 Aug 2011 19:12:45 -0700 (PDT)
Message-ID: <20110803.191245.1720167342434348858.davem@davemloft.net>
References: <CAKh5naZEyehLdP=sHM8H3_+n7ieto0YC_6hn3x=A+y823Gqs-Q@mail.gmail.com>
	<20110803.032632.1644745928704394302.davem@redhat.com>
	<CAKh5naZiFHjQ_q00iBk1kz5XCU9E4wC+7Pxd-8w=v96z-f0Vig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992Ab1HDCMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 22:12:47 -0400
In-Reply-To: <CAKh5naZiFHjQ_q00iBk1kz5XCU9E4wC+7Pxd-8w=v96z-f0Vig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Wed, 3 Aug 2011 15:02:18 +0400

> OMG, sorry for the typo. Here is the correct patch.
> 
> Subject: [PATCH] slip: cleanup statistics generation
> 
> Remove unused tx_compressed, tx_compressed and tx_misses fields from
> the slip structure. Also, make some device stats generation cleanups.
> 
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>

Looks better, applied, thanks.
