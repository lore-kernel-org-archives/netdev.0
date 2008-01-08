From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Wed, 9 Jan 2008 00:28:58 +0100
Message-ID: <20080108232858.GA13069@electric-eye.fr.zoreil.com>
References: <20080108122814.12005.qmail@science.horizon.com> <20080108131956.13905.qmail@science.horizon.com> <20080108213640.GC4450@electric-eye.fr.zoreil.com> <20080108.150038.57735076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60747 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750844AbYAHXmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:42:04 -0500
Content-Disposition: inline
In-Reply-To: <20080108.150038.57735076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Same kind of bug as the RX side :-)  I bet this fixes his
> problem...

I am not sure but the Rx side is probably just here to distract
from the real problem. Please don't ask... :o)

Anyway I'll poke an adapter in the test computer and give it a
try tomorrow. Nobody will complain if I crash it.

-- 
Ueimor
