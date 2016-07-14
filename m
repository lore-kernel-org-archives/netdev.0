From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] sctp: allow GSO frags to access the chunk
 too
Date: Wed, 13 Jul 2016 18:10:29 -0700 (PDT)
Message-ID: <20160713.181029.300582272500283553.davem@davemloft.net>
References: <cover.1468432819.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbcGNBKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 21:10:30 -0400
In-Reply-To: <cover.1468432819.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 13 Jul 2016 15:08:54 -0300

> Patchset is named after the most important fix in it. First two patches
> are preparing the grounds for the 3rd patch.
> 
> After the 3rd, they are not strictly logically related to the patchset,
> but I kept them together as they depend on each other.
> 
> More details on patch changelogs.

Series applied, thanks.
