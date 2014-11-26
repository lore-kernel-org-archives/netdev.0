From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 13/17] bridge: move private brport flags to
 if_bridge.h so port drivers can use flags
Date: Wed, 26 Nov 2014 13:12:43 +0100
Message-ID: <20141126121243.GO1875@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-14-git-send-email-jiri@resnulli.us>
 <20141125224856.GI3912@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:39576 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaKZMMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:12:46 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so4730977wiv.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 04:12:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141125224856.GI3912@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 11:48:56PM CET, tgraf@suug.ch wrote:
>On 11/25/14 at 11:28am, Jiri Pirko wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>> 
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Could be ported to BIT() if you respin.

Done, thanks.
