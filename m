From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net: driver fixes from arm randconfig builds
Date: Thu, 29 Jan 2015 15:08:59 -0800 (PST)
Message-ID: <20150129.150859.1312045066060618087.davem@davemloft.net>
References: <1422454504-439085-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-pcmcia@lists.infradead.org, kas@fi.muni.cz,
	jeffrey.t.kirsher@intel.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbbA2XJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:09:01 -0500
In-Reply-To: <1422454504-439085-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 28 Jan 2015 15:15:00 +0100

> These four patches are fallout from test builds on ARM. I have a
> few more of them in my backlog but have not yet confirmed them
> to still be valid.
> 
> The first three patches are about incomplete dependencies on
> old drivers. One could backport them to the beginning of time
> in theory, but there is little value since nobody would run into
> these problems.
> 
> The final patch is one I had submitted before together with the
> respective pcmcia patch but forgot to follow up on that. It's
> still a valid but relatively theoretical bug, because the previous
> behavior of the driver was just as broken as what we have in
> mainline.

Series applied, thanks Arnd.
