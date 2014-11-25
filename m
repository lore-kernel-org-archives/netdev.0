From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Tue, 25 Nov 2014 14:00:33 -0500
Message-ID: <5474D1D1.4010908@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>	<1416911328-10979-18-git-send-email-jiri@resnulli.us>	<5474A9A4.9070905@mojatatu.com> <CAE4R7bBNvXFYZiOH+cNm_o6PyyQfCXAWrxU7tJzo+pJ+QQSXGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	Aviad Raveh <aviadr@mellanox.com>, nbd@openwrt.org,
	Alexei Starovoitov <alexei.
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:52114 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbaKYTAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:00:38 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so1261726igd.7
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:00:37 -0800 (PST)
In-Reply-To: <CAE4R7bBNvXFYZiOH+cNm_o6PyyQfCXAWrxU7tJzo+pJ+QQSXGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 13:55, Scott Feldman wrote:

> I disagree.  API changes need a reference implementation to show usage
> and for testing.  If you have have an alternate switch implementation
> that achieves the same goal, bring it forward.
>

Yes, point conceded ;->

/me waits for the next guy who is going to smirk at me for saying the
above and tell Jiri to fix his typo ;->


cheers,
jamal
