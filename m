From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 00:35:38 -0700 (PDT)
Message-ID: <20070724.003538.45510068.davem@davemloft.net>
References: <20070723.210748.63127793.davem@davemloft.net>
	<20070724071201.GA7134@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762125AbXGXHfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 03:35:38 -0400
In-Reply-To: <20070724071201.GA7134@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 24 Jul 2007 09:12:01 +0200

> David Miller <davem@davemloft.net> :
> [...]
> > I also didn't play with turning off NAPI in kconfig where drivers
> > allow that, can we just get rid of that crap already? :-/
> 
> Would it be accepted for 2.6.23 or must it be considered post-2.6.23 ?

The 2.6.23 merge window closed already, so this is of course
2.6.24 material.
