From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch iproute2 4/6] bridge/link: add new offload hwmode swdev
Date: Thu, 04 Dec 2014 08:23:14 -0500
Message-ID: <54806042.5010007@mojatatu.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us> <1417683438-10935-5-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:64625 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbaLDNXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 08:23:20 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so15705357iec.29
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 05:23:19 -0800 (PST)
In-Reply-To: <1417683438-10935-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 03:57, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> To support full-featured switch devices offloading bridge funtionality,
> add new hwmode 'swdev'.  Like 'vepa' and 'veb', 'swdev' indicated bridge
> port functionality is being offloaded to hardware.
>

Unhappy with the name swdev ..
Ok, go ahead and beat up on me.

cheers,
jamal
