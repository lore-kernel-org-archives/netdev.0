From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] bridge: rename fdb_*_hw to fdb_*_hw_addr to
 avoid confusion
Date: Tue, 11 Nov 2014 08:20:06 +0100
Message-ID: <20141111072006.GA8106@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415551216-2239-1-git-send-email-jiri@resnulli.us>
 <20141110.213306.1167288435677960869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:45800 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbaKKHUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 02:20:09 -0500
Received: by mail-wi0-f174.google.com with SMTP id d1so711382wiv.1
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 23:20:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141110.213306.1167288435677960869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 11, 2014 at 03:33:06AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sun,  9 Nov 2014 17:40:16 +0100
>
>> The current name might seem that this actually offloads the fdb entry to
>> hw. So rename it to clearly present that this for hardware address
>> addition/removal.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>This must have been relative to your rocket patch series because it
>doesn't apply cleanly.
>
>I already am assuming that the rocket patch set is getting one more
>spin, so why don't you add this to that series?

Will do.

>
>Thanks.
