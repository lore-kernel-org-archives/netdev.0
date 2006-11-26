From: Andi Kleen <ak@suse.de>
Subject: Re: gratuitous arp
Date: Sun, 26 Nov 2006 21:55:09 +0100
Message-ID: <200611262155.09397.ak@suse.de>
References: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:15567 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S935568AbWKZUzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Nov 2006 15:55:21 -0500
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> before i go opening bugs with the distribution folks, could someone chime 
> in as to what is the recommended approach these days?  did grat arp fall 
> out of favour, or is it just a case of userland not keeping up?

The ifup script in iproute2 does it in user land, but nobody uses it
directly

-Andi

