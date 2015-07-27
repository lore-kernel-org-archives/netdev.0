From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 0/4] Introduce Mellanox Technologies Switch ASICs
 switchdev drivers
Date: Mon, 27 Jul 2015 13:21:54 -0700
Message-ID: <CAE4R7bBdDO=d_9dT560dSTo9E0kqcL-sXyF1HqsA-_WHCtPqAw@mail.gmail.com>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35134 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790AbbG0UWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 16:22:14 -0400
Received: by obbop1 with SMTP id op1so68423480obb.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 13:22:14 -0700 (PDT)
In-Reply-To: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This patchset introduces Mellanox Technologies Switch driver infrastructure
> and support for SwitchX-2 ASIC.

You guys did a great job on the driver; looking forward to seeing
L2/L3 hooked up.  Very nice, aesthetically pleasing code.

Is this a ground-up rewrite or a port of the SDK?  It's so clean and
tight, I'm guessing a ground-up rewrite.

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
