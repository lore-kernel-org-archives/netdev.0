From: David Miller <davem@davemloft.net>
Subject: Re: How to do TCP tx checksums
Date: Tue, 17 Nov 2015 14:28:52 -0500 (EST)
Message-ID: <20151117.142852.2076306377938095660.davem@davemloft.net>
References: <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
	<564B677C.8000603@candelatech.com>
	<1447784807.22599.125.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, tom@herbertland.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbbKQT2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:28:53 -0500
In-Reply-To: <1447784807.22599.125.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Nov 2015 10:26:47 -0800

> Anyway, just use trafgen and get ~6 Mpps, more easily than with
> pktgen.

+1
