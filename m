From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 8/8] isdn/capi: return proper errnos on module init
Date: Wed, 14 May 2008 16:49:31 -0700
Message-ID: <20080514164931.5782f897.akpm@linux-foundation.org>
References: <200805142319.m4ENJlhA026572@imap1.linux-foundation.org>
	<20080514.164223.201897276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcin.slusarz@gmail.com, kkeil@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38259 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752837AbYENXuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:50:10 -0400
In-Reply-To: <20080514.164223.201897276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 16:42:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Wed, 14 May 2008 16:19:46 -0700
> 
> > From: Marcin Slusarz <marcin.slusarz@gmail.com>
> > 
> > cdebug_init() is called from kcapi_init() which is module initialization
> > function, so it must return negative values on errors.
> > 
> > Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> > Acked-by: Karsten Keil <kkeil@suse.de>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

hm, what does this mean?  I was hoping for "applied, thanks" ;)
