From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 14:03:05 -0500
Message-ID: <54610BE9.5010106@mojatatu.com>
References: <54603270.509@mojatatu.com>	<20141110074344.GB1850@nanopsycho.orion>	<5460ACC0.3020805@mojatatu.com> <20141110.112857.1873381550982989519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bc
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:44674 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbaKJTDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:03:38 -0500
Received: by mail-ie0-f179.google.com with SMTP id rl12so9920044iec.38
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:03:37 -0800 (PST)
In-Reply-To: <20141110.112857.1873381550982989519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 11:28, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>

>
> Jamal, this is really driving me crazy, this is a non-issue.
>

You are right Dave it is a non-issue, I am sorry. I was still humping on
the wrong tree on the attribute size change.

But please let us have the discussion so the right thing can happen.
I am not trying to beat up on Jiri. I actually think he is doing the
right thing; we just need to make sure input from other people is taken
into consideration because they have implemented on real devices.

cheers,
jamal
