From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: neterion: vxge: vxge-main.c: Cleaning
 up missing null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 14:17:35 -0400 (EDT)
Message-ID: <20140915.141735.2081988681960673592.davem@davemloft.net>
References: <1410716087-16154-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, ebiederm@xmission.com, jg1.han@samsung.com,
	agordeev@redhat.com, benoit.taine@lip6.fr,
	manuel.schoelling@gmx.de, bhutchings@solarflare.com,
	john.stultz@linaro.org, cengelma@gmx.at, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495AbaIOSRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:17:38 -0400
In-Reply-To: <1410716087-16154-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun, 14 Sep 2014 19:34:47 +0200

> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Applied.
