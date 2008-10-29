From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: calculate udp_mem based on low memory instead of
 all memory
Date: Wed, 29 Oct 2008 02:32:05 -0700 (PDT)
Message-ID: <20081029.023205.221909854.davem@davemloft.net>
References: <49082B48.2030905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miquels@cistron.nl
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbYJ2Jca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:32:30 -0400
In-Reply-To: <49082B48.2030905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 29 Oct 2008 10:22:16 +0100

> While working on UDP, I found a comment in udp_init() was outdated.
> 
> This patch could help some 32bit machines, and restore comment validity :)
> 
> No hurry, so I based it on top of my previous patch (net-next-2.6)

Thanks Eric, I'll apply this and also queue it up for submitting to
-stable at some point.
