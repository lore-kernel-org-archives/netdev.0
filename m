From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: Fix an usage of streaming DMA API.
Date: Wed, 14 Mar 2007 10:05:57 +0900 (JST)
Message-ID: <20070314.100557.33857330.nemoto@toshiba-tops.co.jp>
References: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
	<20070314.010220.65192616.anemo@mba.ocn.ne.jp>
	<20070313120418.554a3a43@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org, jeff@garzik.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsns2.toshiba-tops.co.jp ([202.230.225.126]:45575 "EHLO
	topsns2.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752679AbXCNBGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 21:06:03 -0400
In-Reply-To: <20070313120418.554a3a43@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Mar 2007 12:04:18 -0700, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > + *	1.35	Fix an usage of streaming DMA API.
> >   */
> 
> Please don't use comments as changelog anymore. It gets out of date.
> The use of change control systems has made this practice obsolete.

OK, Jeff, should I send a revised patch dropping this line?

---
Atsushi Nemoto
