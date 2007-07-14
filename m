From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] cleanup congestion control options
Date: Fri, 13 Jul 2007 23:54:42 -0700 (PDT)
Message-ID: <20070713.235442.75191469.davem@davemloft.net>
References: <20070714040953.GE3565@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59184
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbXGNGym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 02:54:42 -0400
In-Reply-To: <20070714040953.GE3565@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 14 Jul 2007 06:09:54 +0200

> This patch contains the following cleanups:
> - note in the prompt if an option depends on EXPERIMENTAL
> - remove "default n"s that didn't have any effect
> - remove "default m"s from options under TCP_CONG_ADVANCED:
>   if you manually choose congestion control modules you should
>   know which ones you want
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

I'm not so sure about any of this, sorry Adrian, I'm
not applying this.
