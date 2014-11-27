From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 15/21] rocker: introduce rocker switch driver
Date: Thu, 27 Nov 2014 08:31:26 -0500
Message-ID: <547727AE.9080300@mojatatu.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us> <1417084826-9875-16-git-send-email-jiri@resnulli.us>
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
Received: from mail-ig0-f175.google.com ([209.85.213.175]:59458 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaK0Nba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 08:31:30 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so8526034igd.14
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 05:31:29 -0800 (PST)
In-Reply-To: <1417084826-9875-16-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/14 05:40, Jiri Pirko wrote:
> This patch introduces the first driver to benefit from the switchdev
> infrastructure and to implement newly introduced switch ndos. This is a
> driver for emulated switch chip implemented in qemu:
> https://github.com/sfeldma/qemu-rocker/
>
> This patch is a result of joint work with Scott Feldman.
>


I would like to review the rocking rocks rocker later (sorry dont have
time right now but would love to).

cheers,
jamal
