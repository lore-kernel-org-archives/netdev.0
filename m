From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Wed, 09 Jan 2008 15:56:04 -0800 (PST)
Message-ID: <20080109.155604.11554177.davem@davemloft.net>
References: <20080109003840.22917.qmail@science.horizon.com>
	<20080109.003952.25384040.davem@davemloft.net>
	<20080109233458.GB5673@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@horizon.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756176AbYAIX4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:56:04 -0500
In-Reply-To: <20080109233458.GB5673@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 10 Jan 2008 00:34:58 +0100

> David Miller <davem@davemloft.net> :
> [...]
> > all resolved.  All of that code cleanup stuff needs to wait
> > until later, let's fix bugs before adding new ones. :-)
> 
> Yes.
> 
> I should be able to test your r8169 NAPI changes tomorrow.

Thank you.
