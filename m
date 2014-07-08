From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: l3ni1.c: Fix for possible null pointer
 dereference
Date: Tue, 08 Jul 2014 16:06:43 -0700 (PDT)
Message-ID: <20140708.160643.2062728280845180381.davem@davemloft.net>
References: <1404648277-12419-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaGHXGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 19:06:44 -0400
In-Reply-To: <1404648277-12419-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun,  6 Jul 2014 14:04:37 +0200

> There is otherwise a risk of a possible null pointer dereference.
> 
> Was largely found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied, thanks.
