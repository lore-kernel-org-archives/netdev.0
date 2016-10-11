From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Tue, 11 Oct 2016 13:03:04 +0800
Message-ID: <CAML_gOc92oRxPcc+d+6y6WP_D8ng8W7w9vrJcQhB=q9DcK1R_A@mail.gmail.com>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
 <Pine.LNX.4.64.1610100627230.28174@nacho.alt.net> <CAML_gOeUOrt=-D3VHS2B3B_Q1F2-DAYK95Oxu4FEvfE43hjb3g@mail.gmail.com>
 <Pine.LNX.4.64.1610101818110.28174@nacho.alt.net> <CAML_gOeNcgH-26iL6W5GDf0Ke0Sbpe9MTSULTvTnuiR9Cj_ZLA@mail.gmail.com>
 <alpine.LNX.2.00.1610110353160.3698@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vishwanath Pai <vpai@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        linux-kernel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Chris Caputo <ccaputo@alt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1610110353160.3698@nacho.alt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-10-11 11:57 GMT+08:00 Chris Caputo <ccaputo@alt.net>:
> I have tested the above patch with 4.8.1, with and without nflog-size
> defined in an iptables configuration, and it works well.
>
> The ulogd-2.0.5 segfaults no longer happen when nflog-size is not present
> in a target.
>
> I recommend this fix.

Thanks, I will send an official patch later.
