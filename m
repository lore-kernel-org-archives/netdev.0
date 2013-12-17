From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Tue, 17 Dec 2013 14:56:14 -0500 (EST)
Message-ID: <20131217.145614.1142184518478749309.davem@davemloft.net>
References: <CAK6E8=eeH=6daXoX9Dwe3Nj5LEhKBfL=-2FaLd=Jo7WM-q34qw@mail.gmail.com>
	<20131216193041.GA16966@cpaasch-mac>
	<CAK6E8=e4aQ2qqZ4uBNZBvyYdQ1KER8xashQVAYJoiEUm9sbSew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ja@ssi.bg
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab3LQT4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:56:16 -0500
In-Reply-To: <CAK6E8=e4aQ2qqZ4uBNZBvyYdQ1KER8xashQVAYJoiEUm9sbSew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 16 Dec 2013 11:53:31 -0800

> +1 to get rid of ssthresh caching.

Let's not discuss whether some metrics should be considered for
deletion here because such a discussion is entire separate from
what to key metrics upon.

If you want to talk about potentially removing ssthresh, please
start a new thread.

Thank you.
