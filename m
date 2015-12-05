From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 05 Dec 2015 13:03:13 -0500 (EST)
Message-ID: <20151205.130313.1952213347830357234.davem@davemloft.net>
References: <566279E5.9070500@gmail.com>
	<20151205.014909.1572453190886968569.davem@davemloft.net>
	<CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, hannes@stressinduktion.org,
	linville@tuxdriver.com, jesse@kernel.org, anjali.singhai@intel.com,
	netdev@vger.kernel.org, kiran.patil@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbbLESDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 13:03:17 -0500
In-Reply-To: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 5 Dec 2015 00:24:55 -0800

> Still, hard blocking this isn't necessarily going to push the
> vendors to change their ways.

Pushing back is different from blocking entirely.

That means I'm going to be very difficult and make a lot of noise
until I see the message has seeped in.

It doesn't mean that I won't allow a means to use existing hardware
offloads.  You'll just have to bear with me, be patient, and survive
my tantrum on this matter.
