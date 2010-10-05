From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: checkentry function
Date: Tue, 5 Oct 2010 13:32:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010051331550.4582@obet.zrqbmnf.qr>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com> <20101005144615.0f84d53a@s6510> <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com> <20101005150147.62226282@s6510> <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
 <1286259838.2457.11.camel@edumazet-laptop> <AANLkTinVtz0VuLkOY5d8QjdvLMXOFD2EaWp_kSBbMJBW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinVtz0VuLkOY5d8QjdvLMXOFD2EaWp_kSBbMJBW@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 2010-10-05 13:16, Nicola Padovano wrote:
>>
>> Could you read source code of _current_ existing modules , and use
>> copy/paste ?
>>
>> static int hashlimit_mt_check(const struct xt_mtchk_param *par)
>> {
>> ...
>> }
>
>as i've written in a previously mail this is the checkentry function
>that i use in my source code to check if the iptables command line is
>a right line.
>
>[CHECK_ENTRY_CODE]
>static bool xt_tarpit_check(const char *tablename, const void *entry,
>                           const struct xt_target *target, void *targinfo,
>                           unsigned int hook_mask)
>
>i don't know what "static int hashlimit_mt_check(const struct
>xt_mtchk_param *par)" is...

It's the proper function header.
