From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 04/12] via-velocity: give a structure to the rx / tx
	fields
Date: Thu, 31 Jul 2008 23:59:19 +0200
Message-ID: <20080731215919.GA32256@electric-eye.fr.zoreil.com>
References: <200807301938.m6UJcv2a012508@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37087 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758666AbYGaWAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 18:00:55 -0400
Content-Disposition: inline
In-Reply-To: <200807301938.m6UJcv2a012508@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org <akpm@linux-foundation.org> :
> From: Francois Romieu <romieu@fr.zoreil.com>
> 
> Separated struct allow wholesale copy during MTU changes.

Yes, I forgot to rediff it after it failed to apply to Jeff's tree.

Patches #4 + #5 make sense as a bugfix.

It is available at:
git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git via-velocity

(branched from the latest merge-base of davem / linus)

-- 
Ueimor
