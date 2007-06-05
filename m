From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] 2.6.22-rc4: known regressions with patches
Date: Tue, 05 Jun 2007 16:07:35 -0700 (PDT)
Message-ID: <20070605.160735.71091132.davem@davemloft.net>
References: <46657924.4010505@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
	uwe.bugla@gmx.de, kenchen@google.com, dwmw2@infradead.org,
	Artem.Bityutskiy@nokia.com, hskinnemoen@atmel.com,
	clameter@sgi.com, airlied@linux.ie,
	righiandr@users.sourceforge.net, netdev@vger.kernel.org,
	a.strobl@aws-it.at, kaber@trash.net
To: michal.k.k.piotrowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765046AbXFEXHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 19:07:21 -0400
In-Reply-To: <46657924.4010505@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Date: Tue, 05 Jun 2007 16:54:28 +0200

> Networking
> 
> Subject    : OOPS iproute2/tc/u32_destroy in 2.6.22-rc3-git6
> References : http://lkml.org/lkml/2007/6/3/66
> Submitter  : Strobl Anton <a.strobl@aws-it.at>
> Handled-By : Patrick McHardy <kaber@trash.net>
> Patch      : http://lkml.org/lkml/2007/6/3/137
> Status     : patch available

This slipped through the cracks, I've applied Patrick's
patch and will push upstream.

Thanks!
