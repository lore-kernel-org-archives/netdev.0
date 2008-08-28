From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139too: fix improper usage of workqueue
Date: Thu, 28 Aug 2008 22:48:40 +0200
Message-ID: <20080828204840.GA29446@electric-eye.fr.zoreil.com>
References: <20080827085126.29e673db@extreme> <20080827192656.GA27499@electric-eye.fr.zoreil.com> <20080827131649.409acf91@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57317 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753591AbYH1Usn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:48:43 -0400
Content-Disposition: inline
In-Reply-To: <20080827131649.409acf91@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> :
[...]
> flush_scheduled_work only impacts work already scheduled not delayed.

Ok. I was confused.

> How about this (simpler) version.

Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
