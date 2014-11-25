From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 07/17] rocker: introduce rocker switch driver
Date: Tue, 25 Nov 2014 09:19:17 -1000
Message-ID: <CAE4R7bC=jnq=OX2BNa9hpzbx8fpxHF+zGf1cV1ahP31htpE7kQ@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-8-git-send-email-jiri@resnulli.us>
	<063D6719AE5E284EB5DD2968C1650D6D1C9FB50A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"f
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:45144 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaKYTTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:19:19 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so2551930wiw.15
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:19:17 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9FB50A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 6:13 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Jiri Pirko
>>
>> This patch introduces the first driver to benefit from the switchdev
>> infrastructure and to implement newly introduced switch ndos. This is a
>> driver for emulated switch chip implemented in qemu:
>> https://github.com/sfeldma/qemu-rocker/
>
> If this driver caller 'rocker' just to get the (bad) pun 'rocker switch'?
> IMHO A more descriptive name would be a lot better.

Sorry, it's the best we could do since qla3xxx and mlx4 and fm10k were
already taken.
