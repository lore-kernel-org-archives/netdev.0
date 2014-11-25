From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Tue, 25 Nov 2014 11:09:08 -0500
Message-ID: <5474A9A4.9070905@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-18-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
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
Received: from mail-ig0-f169.google.com ([209.85.213.169]:58854 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaKYQJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:09:12 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so7026551igb.0
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:09:11 -0800 (PST)
In-Reply-To: <1416911328-10979-18-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Rocker ports will use new "swdev" hwmode for bridge port offload policy.
> Current supported policy settings are BR_LEARNING and BR_LEARNING_SYNC.
> User can turn on/off device port FDB learning and syncing to bridge.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

as previous comments - please submit rocker separately

cheers,
jamal
