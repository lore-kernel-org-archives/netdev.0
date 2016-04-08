From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: Fix broken of_node_put() code.
Date: Fri, 08 Apr 2016 16:15:57 -0400 (EDT)
Message-ID: <20160408.161557.850174112269792582.davem@davemloft.net>
References: <1459472517-5696-1-git-send-email-ddaney.cavm@gmail.com>
	<5707DF3F.3000508@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	rric@kernel.org, sgoutham@cavium.com, david.daney@cavium.com
To: ddaney@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5707DF3F.3000508@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Fri, 8 Apr 2016 09:41:35 -0700

> Due to mail server malfunction, this patch was sent twice.  Please
> ignore this duplicate.

This submission had another problem too.

Do not use the date of your commit as the date that gets put into
your email headers.

This makes all of your patch submissions look like they occurred in
the past, and this mixes up the ordering of patches in patchwork.

So please resubmit this properly with a normal, current, date in your
email headers.

Thanks.
