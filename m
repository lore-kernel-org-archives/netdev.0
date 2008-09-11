From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3 v2] ibm_newemac: Various fixes and additions for
 PPC405EZ
Date: Wed, 10 Sep 2008 23:21:03 -0400
Message-ID: <20080910232103.15a9b87e@zod.rchland.ibm.com>
References: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:38687 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbYIKDVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 23:21:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8B3L7ep018181
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 23:21:07 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8B3L7DS235740
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 23:21:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8B3L7iG021953
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 23:21:07 -0400
In-Reply-To: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Sep 2008 08:44:59 -0400
Josh Boyer <jwboyer@linux.vnet.ibm.com> wrote:

> The following patch series adds things needed to support the PowerPC 405EZ
> SoC.  I've incorporated the suggestions and fixes from the previous round
> of patches and barring any further comments these should be ready to go.
> 
> josh
> 
> Josh Boyer (3):
>   ibm_newemac: Allow the "no flow control" EMAC feature to work
>   ibm_newemac: Introduce mal_has_feature
>   ibm_newemac: MAL support for PowerPC 405EZ

I should mention that I have a platform support patch series that
depends on these for working ethernet.  I can bring this set in through
my tree at the same time if the patches look fine and Jeff acks that.

josh
