From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 01/17] bridge: rename fdb_*_hw to fdb_*_hw_addr
 to avoid confusion
Date: Tue, 25 Nov 2014 10:26:27 -0500
Message-ID: <54749FA3.4000104@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-2-git-send-email-jiri@resnulli.us>
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
Received: from mail-ie0-f173.google.com ([209.85.223.173]:39797 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaKYP0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:26:36 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so719455ier.32
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 07:26:35 -0800 (PST)
In-Reply-To: <1416911328-10979-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> The current name might seem that this actually offloads the fdb entry to
> hw. So rename it to clearly present that this for hardware address
> addition/removal.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
