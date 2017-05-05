From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 0/9] net: thunderx: Adds XDP support
Date: Fri, 5 May 2017 15:40:27 +0530
Message-ID: <CA+sq2CfsCkyV1A9UnVEzSoONjLXdgjcwRm8jD-FsULop0a9feQ@mail.gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
 <20170502.154744.1762061314370744901.davem@davemloft.net> <CA+sq2CfW89EbiZmp6byc3y3cbATmmyVB=avzrUXG51-x3yxckg@mail.gmail.com>
 <CAKoUArku6tRuV=Y3fteY-R6eHM4daq-0ct6w1_unjkGA+yPTFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sunil Goutham <sgoutham@cavium.com>,
        LAKML <linux-arm-kernel@lists.infradead.org>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKoUArku6tRuV=Y3fteY-R6eHM4daq-0ct6w1_unjkGA+yPTFQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 4, 2017 at 2:09 AM, Rami Rosen <roszenrami@gmail.com> wrote:
> Thanks, Sunil.
>
>>with network stack: 0.32 Mpps
>>with XDP (XDP_TX): 3 Mpps
>>and XDP_DROP: 3.8 Mpps
>
> Interesting; May I ask - which packet size did you use ?

Packet size is 64bytes.

Thanks,
Sunil.

>
> Regards,
> Rami Rosen
