From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Sat, 30 Jun 2007 21:30:03 +0200
Message-ID: <20070630193003.GA21140@electric-eye.fr.zoreil.com>
References: <200704162241.31729.peter.missel@onlinehome.de> <200705012119.48598.peter.missel@onlinehome.de> <20070501200723.GA19212@electric-eye.fr.zoreil.com> <200706301448.50541.peter.missel@onlinehome.de> <20070630133810.GA15951@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Peter Missel <peter.missel@onlinehome.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41381 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbXF3TcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 15:32:15 -0400
Content-Disposition: inline
In-Reply-To: <20070630133810.GA15951@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> The patch will not apply directly against 2.6.21.5. Is it an option for
> you to try 2.6.22-rc6 or are you stuck with 2.6.21.5 ?

If you feel adventurous, you will find a compile-tested-only patchkit for
2.6.21.5 here:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21.5
or:
http://www.fr.zoreil.com/people/francois/misc/20060630-2.6.21.5-r8169-test.patch

The content should be almost the same as the 2.6.22-rc6 patchkit dated
from 2007/06/28 (i.e. pending 2.6.23 merge).

Time to go downtown. The lights are much brighter there.

-- 
Ueimor
