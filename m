From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/11 net-next] TIPC cleanups for native API removal
Date: Thu, 02 Dec 2010 13:34:41 -0800 (PST)
Message-ID: <20101202.133441.116375492.davem@davemloft.net>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59544
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752971Ab0LBVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:34:14 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 30 Nov 2010 17:00:52 -0500

> The purge of the unused code that existed just to support the draft
> API spec (commit 31e3c3f6f1f9b154981a0e6620df700463db30ee) actually
> opens the door for several more cleanups of similar nature.  It is
> possible to relocate and internalize header file content, reduce the
> number of exported symbols further, and manually inline some of the
> "used once" functions that used to be separate just to be exported.
> 
> Some other largely trivial one-off type cleanups are also included.
> Overall, this set of commits should largely be a no-op in terms of
> behaviour change though.

Looks great, all applied, thanks!
