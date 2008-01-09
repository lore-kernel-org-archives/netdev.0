From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Thu, 10 Jan 2008 00:34:58 +0100
Message-ID: <20080109233458.GB5673@electric-eye.fr.zoreil.com>
References: <20080108213640.GC4450@electric-eye.fr.zoreil.com> <20080109003840.22917.qmail@science.horizon.com> <20080109.003952.25384040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54466 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754209AbYAIXvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:51:52 -0500
Content-Disposition: inline
In-Reply-To: <20080109.003952.25384040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> all resolved.  All of that code cleanup stuff needs to wait
> until later, let's fix bugs before adding new ones. :-)

Yes.

I should be able to test your r8169 NAPI changes tomorrow.

-- 
Ueimor
