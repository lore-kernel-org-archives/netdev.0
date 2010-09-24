From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 15/24] net: change to new flag variable
Date: Fri, 24 Sep 2010 15:25:04 -0400
Message-ID: <20100924192504.GG8077@tuxdriver.com>
References: <e0bdab5d2e8c52041c003de68ba774c3e706716c.1285355033.git.mfm@muteddisk.com>
 <facbf79cadc81f9043e89160b7b3b8a90926aba1.1285355033.git.mfm@muteddisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Jouni Malinen <j@w1.fi>, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: matt mooney <mfm@muteddisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55785 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757879Ab0IXT3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 15:29:39 -0400
Content-Disposition: inline
In-Reply-To: <facbf79cadc81f9043e89160b7b3b8a90926aba1.1285355033.git.mfm@muteddisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 24, 2010 at 12:17:25PM -0700, matt mooney wrote:
> Replace EXTRA_CFLAGS with ccflags-y.
> 
> Signed-off-by: matt mooney <mfm@muteddisk.com>
> ---
>  drivers/net/wireless/hostap/hostap_config.h |    4 ++--
>  drivers/net/wireless/zd1211rw/Makefile      |    4 +---

ACK for these bits...

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
