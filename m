From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Sun, 26 Apr 2009 23:36:38 -0700 (PDT)
Message-ID: <20090426.233638.83897914.davem@davemloft.net>
References: <49F53FF6.2040603@cosmosbay.com>
	<20090427054702.GA15891@kryten>
	<49F54CC5.7020600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53320
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753917AbZD0Ggo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:36:44 -0400
In-Reply-To: <49F54CC5.7020600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 27 Apr 2009 08:12:21 +0200

> A similar patch was done for the size of TCP hash table. It was something
> like 512 * 1024 if I remember well. IMHO this same value would be fine for
> IP route cache.
> 
> Yes, this was commit :

Fair enough, I'd be OK with this if you'd be too :)
