From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] bridge: rename fdb_*_hw to fdb_*_hw_addr to
 avoid confusion
Date: Mon, 10 Nov 2014 21:33:06 -0500 (EST)
Message-ID: <20141110.213306.1167288435677960869.davem@davemloft.net>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415551216-2239-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaKKCdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:33:14 -0500
In-Reply-To: <1415551216-2239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  9 Nov 2014 17:40:16 +0100

> The current name might seem that this actually offloads the fdb entry to
> hw. So rename it to clearly present that this for hardware address
> addition/removal.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

This must have been relative to your rocket patch series because it
doesn't apply cleanly.

I already am assuming that the rocket patch set is getting one more
spin, so why don't you add this to that series?

Thanks.
