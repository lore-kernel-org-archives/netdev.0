From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c_main.c: add wait_for_idle routine
Date: Mon, 01 Jun 2009 03:14:14 -0700 (PDT)
Message-ID: <20090601.031414.240581040.davem@davemloft.net>
References: <1243838695.3402.17.camel@Joe-Laptop.home>
	<72981EBCFD196144B7C6999B9FC34A9A418BFD1261@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, yanghy@cn.fujitsu.com,
	akpm@linux-foundation.org
To: Jie.Yang@Atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755297AbZFAKOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:14:14 -0400
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A418BFD1261@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <Jie.Yang@Atheros.com>
Date: Mon, 1 Jun 2009 14:59:17 +0800

> On  Monday, June 01, 2009 2:45 PM
> Joe Perches <joe@perches.com> wrote:
>> Slight refactoring of duplicated wait for idle checks Spelling fix
>>
>> Signed-off-by: Joe Perches <joe@perches.com>
...
> Acked-by: jie.yang@atheros.com

Applied to net-next-2.6, thanks.
