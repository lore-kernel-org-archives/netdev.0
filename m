From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] printk: add %I4, %I6, %i4, %i6 format specifiers
Date: Wed, 29 Oct 2008 13:04:18 -0700 (PDT)
Message-ID: <20081029.130418.253493508.davem@davemloft.net>
References: <1225305340.5688.36.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753234AbYJ2UEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 16:04:43 -0400
In-Reply-To: <1225305340.5688.36.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 29 Oct 2008 11:35:40 -0700

> For use in printing IPv4, or IPv6 addresses in the usual way:
> 
> %i4 and %I4 are currently equivalent and print the address in
> dot-separated decimal x.x.x.x
> 
> %I6 prints 16-bit network order hex with colon separators:
> xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
> 
> %i6 omits the colons.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
