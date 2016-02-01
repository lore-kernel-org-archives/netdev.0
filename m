From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Mon, 1 Feb 2016 12:04:28 -0800
Message-ID: <CALx6S35-hZSgO44ZwLCYiTj8uSRKATymX2O1adn_9Nr9uvg+GQ@mail.gmail.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
	<1454159878-20706-3-git-send-email-tanure@linux.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD2580@AcuExch.aculab.com>
	<20160201.114135.1043954624527820660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>, tanure@linux.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160201.114135.1043954624527820660.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 1, 2016 at 11:41 AM, David Miller <davem@davemloft.net> wrote:
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Mon, 1 Feb 2016 16:37:41 +0000
>
>> From: Lucas Tanure
>>> Sent: 30 January 2016 13:18
>>> As suggested by checkpatch.pl:
>>> CHECK: Prefer kernel type 'uX' over 'uintX_t'
>>
>> One might ask why?
>
> We have consistently done this, and consistency is enough of an
> argument.

Also, uintX_t is verbose and does not add anything to readability.
