From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 13:57:05 -0800
Message-ID: <546134B1.7010707@gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
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
	bcrl@kvac
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:47691 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbaKJV5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 16:57:43 -0500
Received: by mail-oi0-f46.google.com with SMTP id g201so6142207oib.33
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 13:57:43 -0800 (PST)
In-Reply-To: <1415530280-9190-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2014 02:51 AM, Jiri Pirko wrote:
> So this can be reused for identification of other "items" as well.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Looks good to me. Just a simple code refactoring and doesn't
touch any user visible uapi files and makes the next patches a
bit cleaner.

Acked-by: John Fastabend <john.r.fastabend@intel.com>


-- 
John Fastabend         Intel Corporation
