From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARM: fix typos in smc91x platform data
Date: Wed, 04 Mar 2015 23:33:22 -0500 (EST)
Message-ID: <20150304.233322.2161418715687567572.davem@davemloft.net>
References: <20150228.125721.1605776377351425463.davem@davemloft.net>
	<55454365.1GsbtFBXGk@wuerfel>
	<3483843.L07cLWCFPN@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linus.walleij@linaro.org, robert.jarzmik@free.fr,
	linux@arm.linux.org.uk, arm@kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbCEEd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:33:28 -0500
In-Reply-To: <3483843.L07cLWCFPN@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 04 Mar 2015 23:39:18 +0100

> I recently did a rework of the smc91x driver and did some build-testing
> by compiling hundreds of randconfig kernels. Unfortunately, my script
> was wrong and did not actually test the configurations that mattered,
> so I introduced stupid typos in almost every file I touched.
> 
> I fixed my script now, built all configurations that actually matter
> and fixed all the typos, this is the result.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: b70661c70830d ("net: smc91x: use run-time configuration on all ARM machines")

Applied, thanks.
