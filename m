From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 0/4] Introduce Mellanox Technologies Switch ASICs
 switchdev drivers
Date: Mon, 27 Jul 2015 14:21:14 -0700
Message-ID: <55B6A0CA.4010207@gmail.com>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us> <CAE4R7bBdDO=d_9dT560dSTo9E0kqcL-sXyF1HqsA-_WHCtPqAw@mail.gmail.com> <20150727202747.GA2123@nanopsycho.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, idosch@mellanox.com,
	eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33366 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbbG0VXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:23:18 -0400
Received: by padck2 with SMTP id ck2so57377595pad.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:23:17 -0700 (PDT)
In-Reply-To: <20150727202747.GA2123@nanopsycho.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/07/15 13:27, Jiri Pirko wrote:
> Mon, Jul 27, 2015 at 10:21:54PM CEST, sfeldma@gmail.com wrote:
>> On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> This patchset introduces Mellanox Technologies Switch driver infrastructure
>>> and support for SwitchX-2 ASIC.
>>
>> You guys did a great job on the driver; looking forward to seeing
>> L2/L3 hooked up.  Very nice, aesthetically pleasing code.
> 
> Thanks!
> 
>>
>> Is this a ground-up rewrite or a port of the SDK?  It's so clean and
>> tight, I'm guessing a ground-up rewrite.
> 
> It's rewritten from scratch.

Only glanced through the driver, but this looks like really really nice
and clean, very pleased to see such a driver being submitted. That is
very encouraging and should inspire other companies in doing so, so
thanks for doing this!
-- 
Florian
