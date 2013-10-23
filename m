From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: BUG: scheduling while atomic dev_set_promiscuity->__dev_notify_flags
Date: Wed, 23 Oct 2013 14:18:34 +0200
Message-ID: <5267BE9A.90504@6wind.com>
References: <CAMEtUuy91zYJ=bj1dzfdqE8kqZ3rE1RgdR-PZYekSUg8_xoTBw@mail.gmail.com>	<slrnl6ei2u.vgu.xiyou.wangcong@linux-6brj.site> <CAADnVQLY7-crQLO1Tc4MBLX8R66wAZztw-arnfO3NWO9sLW++Q@mail.gmail.com> <52677F30.1070800@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:43395 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab3JWMSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 08:18:37 -0400
Received: by mail-wi0-f178.google.com with SMTP id hn9so753938wib.17
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 05:18:36 -0700 (PDT)
In-Reply-To: <52677F30.1070800@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/10/2013 09:48, Nicolas Dichtel a =E9crit :
> Le 23/10/2013 07:34, Alexei Starovoitov a =E9crit :
>> On Tue, Oct 22, 2013 at 8:53 PM, Cong Wang <xiyou.wangcong@gmail.com=
> wrote:
>>> On Tue, 22 Oct 2013 at 01:04 GMT, Alexei Starovoitov <ast@plumgrid.=
com> wrote:
>>>>
[snip]
>> Nicolas, I've sent you my .config.
> I got some pb with my testbed, hence I still didn't reproduce the bug=
=2E
> I will make more test today, but I think this is the right patch.
Still not reproduced with your config.
But as I said, I think your patch is the right thing to do.
