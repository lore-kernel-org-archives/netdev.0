From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Jumbo frame question...
Date: Fri, 24 Jul 2009 14:45:52 -0400
Message-ID: <20090724184552.GA2991@csclub.uwaterloo.ca>
References: <200907241141.55097.rgetz@blackfin.uclinux.org> <20090724.093243.201296391.davem@davemloft.net> <4A69E3CF.1040805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rgetz@blackfin.uclinux.org,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:41849 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753537AbZGXSpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 14:45:52 -0400
Content-Disposition: inline
In-Reply-To: <4A69E3CF.1040805@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2009 at 09:39:43AM -0700, Rick Jones wrote:
> In so far as there is no de jure spec for Jumbo Frames, it is rather 
> difficult to have a spec violation :).
>
> Not a case of too much rope?  Given that (IIRC) Jumbo Frame was not 
> introduced in Ethernet NICs until Gigabit came along (eg Alteon), the 
> chances a (legacy) 100 Mbit/s network would have JF-capable NICs is 
> epsilon.

Nothing would prevent you from using a 100Mbit fiber PHY on a gigabit
capable network port, so you could have a 100Mbit port that supported
jumbo frames.

-- 
Len Sorensen
