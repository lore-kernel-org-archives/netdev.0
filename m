From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] Introduce Mellanox Technologies Switch
 ASICs switchdev drivers
Date: Mon, 27 Jul 2015 22:27:47 +0200
Message-ID: <20150727202747.GA2123@nanopsycho.fritz.box>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bBdDO=d_9dT560dSTo9E0kqcL-sXyF1HqsA-_WHCtPqAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, idosch@mellanox.com,
	eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
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
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36432 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbbG0U1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 16:27:51 -0400
Received: by wicgb10 with SMTP id gb10so128262353wic.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 13:27:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBdDO=d_9dT560dSTo9E0kqcL-sXyF1HqsA-_WHCtPqAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 27, 2015 at 10:21:54PM CEST, sfeldma@gmail.com wrote:
>On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This patchset introduces Mellanox Technologies Switch driver infrastructure
>> and support for SwitchX-2 ASIC.
>
>You guys did a great job on the driver; looking forward to seeing
>L2/L3 hooked up.  Very nice, aesthetically pleasing code.

Thanks!

>
>Is this a ground-up rewrite or a port of the SDK?  It's so clean and
>tight, I'm guessing a ground-up rewrite.

It's rewritten from scratch.

>
>Reviewed-by: Scott Feldman <sfeldma@gmail.com>

Thanks for your review!
