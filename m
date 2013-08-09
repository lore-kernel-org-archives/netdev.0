From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to
 shared header
Date: Fri, 09 Aug 2013 11:04:07 -0700 (PDT)
Message-ID: <20130809.110407.839655411843744960.davem@davemloft.net>
References: <CAOMZO5AHVcmb8DiqM_H12e9cD3zAt0ZGz8yrLDyq5FwwO+cSMA@mail.gmail.com>
	<20130809104016.236fcd9d@nehalam.linuxnetplumber.net>
	<1376070636.20509.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, festevam@gmail.com, broonie@kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, broonie@linaro.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758536Ab3HISEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:04:10 -0400
In-Reply-To: <1376070636.20509.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Aug 2013 10:50:36 -0700

> Some compiler folk decided 'extern' were not mandatory for code, but its
> really adding confusion and endless discussions.

I certainly stopped talking about it, you could too :-)
