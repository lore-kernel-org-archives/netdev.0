From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h:
 remove unused macro pr_fmt()
Date: Tue, 15 Nov 2011 15:52:10 -0800
Message-ID: <20111115155210.69249eb9.akpm@linux-foundation.org>
References: <201111152255.pAFMtTo5005370@wpaz5.hot.corp.google.com>
	<20111115.183808.2066749950387258221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	tomoya-linux@dsn.okisemi.com, toshiharu-linux@dsn.okisemi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:60154 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757039Ab1KOXwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 18:52:13 -0500
In-Reply-To: <20111115.183808.2066749950387258221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Nov 2011 18:38:08 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Tue, 15 Nov 2011 14:55:29 -0800
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h: remove unused macro pr_fmt()
> 
> It's not unused, it just isn't properly coming before the linux/printk.h
> include.

Oh well, I'll drop it.  Please treat the patch as a bug report instead.
