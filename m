From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] rtnetlink.c: #if 0 no longer used functions
Date: Thu, 31 Jan 2008 17:17:51 -0800 (PST)
Message-ID: <20080131.171751.192428440.davem@davemloft.net>
References: <20080130200257.GD29368@does.not.exist>
	<47A0D851.9050408@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44279
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765177AbYBABRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:17:30 -0500
In-Reply-To: <47A0D851.9050408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 30 Jan 2008 21:04:33 +0100

> Adrian Bunk wrote:
> > This patch #if 0's the following no longer used functions:
> > - rtattr_parse()
> > - rtattr_strlcpy()
> > - __rtattr_parse_nested_compat()
> >   
> 
> Please remove them instead.

Agreed.
