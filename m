From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] Refactor update of IPv6 flowi destination address
 for srcrt (RH) option
Date: Wed, 02 Jun 2010 07:08:52 -0700 (PDT)
Message-ID: <20100602.070852.171505220.davem@davemloft.net>
References: <8739x6d0ky.fsf@small.ssi.corp>
	<1275422925.19372.114.camel@Joe-Laptop.home>
	<87sk55q44a.fsf_-_@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42212
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751489Ab0FBOIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:08:43 -0400
In-Reply-To: <87sk55q44a.fsf_-_@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Wed, 02 Jun 2010 09:35:01 +0200

> Here is a v3 based on the comments I received from Joe. The helper is
> now in exthdrs.c (no more inline) and has a proper name.
> 
> Applies on net-2.6. Tested on 2.6.34.

Looks good, applied to net-next-2.6, thanks.
