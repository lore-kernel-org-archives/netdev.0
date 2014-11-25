From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 13/17] bridge: move private brport flags to
 if_bridge.h so port drivers can use flags
Date: Tue, 25 Nov 2014 14:20:56 -0800
Message-ID: <547500C8.7040807@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-14-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:52561 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaKYWVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:21:00 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so1457744pad.38
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:21:00 -0800 (PST)
In-Reply-To: <1416911328-10979-14-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 02:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
