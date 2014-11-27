From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Thu, 27 Nov 2014 07:46:01 -0500
Message-ID: <54771D09.5010601@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>	<1416911328-10979-5-git-send-email-jiri@resnulli.us>	<5474A567.4040401@mojatatu.com>	<20141125164954.GJ1971@nanopsycho.orion>	<5474B795.3080204@mojatatu.com>	<20141125215402.GA3912@casper.infradead.org>	<54754A10.6020601@mojatatu.com>	<CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>	<5475BB53.3070200@mojatatu.com> <CAE4R7bC2GTOAHm6uN9CboQ8HRFQ0+-7yoK+XF3wUysA9Sbo=gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:40023 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaK0MqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 07:46:06 -0500
Received: by mail-ig0-f171.google.com with SMTP id z20so4423120igj.4
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 04:46:05 -0800 (PST)
In-Reply-To: <CAE4R7bC2GTOAHm6uN9CboQ8HRFQ0+-7yoK+XF3wUysA9Sbo=gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/14 00:58, Scott Feldman wrote:


> You have access to the inside scope.  We don't.  Ok, I don't.  We
> (think we) know what the traditional L2/L3 and OVS-style flow stuff
> looks like, but you know more, but you can't show us in code so it's
> frustrating.  Not your fault.  Just continue to guide us and give some
> disclaimer when we're your close to some proprietary knowledge, but it
> is relevant to the discussion.
>


Scott, I am asking to offload basic functionality that Linux supports.
I may be blind-sided and getting frustrated thinking it is obvious
because i live through this stuff everyday; but I am trying all i can
to share what you call proprietary knowledge whenever i can. If you
think of this as "we need to offload all packet processing linux
supports" you'll see where i am coming from.

cheers,
jamal
