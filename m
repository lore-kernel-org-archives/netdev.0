From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Tue, 25 Nov 2014 21:42:03 +0100
Message-ID: <20141125204203.GQ1971@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-18-git-send-email-jiri@resnulli.us>
 <5474A9A4.9070905@mojatatu.com>
 <CAE4R7bBNvXFYZiOH+cNm_o6PyyQfCXAWrxU7tJzo+pJ+QQSXGg@mail.gmail.com>
 <5474D1D1.4010908@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
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
	Alexei Starovoitov <ale
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:41741 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbaKYUmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 15:42:05 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so1899254wgh.26
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 12:42:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5474D1D1.4010908@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 08:00:33PM CET, jhs@mojatatu.com wrote:
>On 11/25/14 13:55, Scott Feldman wrote:
>
>>I disagree.  API changes need a reference implementation to show usage
>>and for testing.  If you have have an alternate switch implementation
>>that achieves the same goal, bring it forward.
>>
>
>Yes, point conceded ;->
>
>/me waits for the next guy who is going to smirk at me for saying the
>above and tell Jiri to fix his typo ;->

Yep, people do not read replies :)
