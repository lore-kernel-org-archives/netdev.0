From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [resend take 3 0/4] Distributed storage.
Date: Wed, 26 Nov 2008 11:31:18 +0300
Message-ID: <20081126083118.GA21558@ioremap.net>
References: <12276238703113-git-send-email-zbr@ioremap.net> <20081125234707.GG5324@gambetta>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:43636 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbYKZIbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 03:31:20 -0500
Content-Disposition: inline
In-Reply-To: <20081125234707.GG5324@gambetta>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Frederik.

On Wed, Nov 26, 2008 at 12:47:07AM +0100, Frederik Deweerdt (frederik.deweerdt@xprog.eu) wrote:
> The attached patch is needed to compile against 2.6.28-rc6 (changes in
> block_devices_operations), I added a few cleanups as well.

I will queue it for inclusion, when will rebase against latest tree.
Patches are against stable tree, so this may make some confusion.

Thank you.

-- 
	Evgeniy Polyakov
