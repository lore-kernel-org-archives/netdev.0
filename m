From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/xfrm/: remove unused exports
Date: Thu, 31 Jan 2008 17:10:39 -0800 (PST)
Message-ID: <20080131.171039.126325211.davem@davemloft.net>
References: <20080130200221.GR29368@does.not.exist>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, paul.moore@hp.com,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753654AbYBABKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:10:17 -0500
In-Reply-To: <20080130200221.GR29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 30 Jan 2008 22:02:21 +0200

> This patch removes the following no longer used EXPORT_SYMBOL's:
> - xfrm_input.c: xfrm_parse_spi
> - xfrm_state.c: xfrm_replay_check
> - xfrm_state.c: xfrm_replay_advance
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
