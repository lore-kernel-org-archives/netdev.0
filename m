From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 3/9] tunnel: introduce udp_tun_rx_dst()
Date: Thu, 20 Aug 2015 13:36:10 -0700
Message-ID: <CALnjE+q-KH_cc9TC9LHp7WNijHKX=r+LSQGYeDoq09Vb9dk3sA@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-4-git-send-email-pshelar@nicira.com>
	<20150820165600.GC8475@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38500 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbbHTUgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:36:11 -0400
Received: by igfj19 with SMTP id j19so49192igf.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 13:36:10 -0700 (PDT)
In-Reply-To: <20150820165600.GC8475@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 9:56 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/17/15 at 02:11pm, Pravin B Shelar wrote:
>> Introduce function udp_tun_rx_dst() to initialize tunnel dst on
>> receive path.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> Reviewed-by: Jesse Gross <jesse@nicira.com>
>
> This looks great but conflicts with Jiri Benc's IPv6 series. Can we
> rebase this on top of his work so we get IPv6 support in the new
> helpers from the beginning?

Yes, I will post rebased series after Jiri Benc's patch series is pushed.
