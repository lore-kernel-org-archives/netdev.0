From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 19 Sep 2014 11:25:48 -0400
Message-ID: <541C4AFC.8060500@mojatatu.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@intel.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:47248 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755682AbaISPZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 11:25:51 -0400
Received: by mail-ie0-f178.google.com with SMTP id at20so3736912iec.37
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 08:25:51 -0700 (PDT)
In-Reply-To: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/14 09:49, Jiri Pirko wrote:
> This patch exposes switchdev API using generic Netlink.
> Example userspace utility is here:
> https://github.com/jpirko/switchdev
>

Is this just a temporary test tool? Otherwise i dont see reason
for its existence (or the API that it feeds on).

cheers,
jamal
