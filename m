From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH, regression against -rc6] net/stmmac: fix one more regression from filter bins setting
Date: Sat, 29 Nov 2014 17:29:30 +0100
Message-ID: <4809570.05nXhLpYaA@wuerfel>
References: <5388366.Y15J6TLmlA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, khilman@kernel.org,
	Huacai Chen <chenhc@lemote.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>, olof@lixom.net,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:52089 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaK2QaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 11:30:04 -0500
In-Reply-To: <5388366.Y15J6TLmlA@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 29 November 2014 13:03:19 Arnd Bergmann wrote:
> I've sent this off to the build bots, but it will probably take some more
> time before it's been tested on all the ARM machines and I might not be
> there to see the results, so I'm sending it out now for review. I will
> reply once I am sure the problem is fixed.

With this patch applied, both boot bots are back to 100% success now,
all eight failing machines are working again.

	Arnd
