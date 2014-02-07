From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: Re: [PATCH net] tg3: Fix deadlock in tg3_change_mtu()
Date: Thu, 6 Feb 2014 17:08:41 -0800
Message-ID: <52F43219.8010809@broadcom.com>
References: <1391724785-13562-1-git-send-email-nsujir@broadcom.com> <20140206.165448.1676259324527494823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<stable@vger.kernel.org>, <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140206.165448.1676259324527494823.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 02/06/2014 04:54 PM, David Miller wrote:
>
> Networking patches should never be CC:'d to -stable.  And you should
> never add the:
>
> Cc: <stable@vger.kernel.org>
>
> tag to networking commit messages.
>
> Instead, after the "---" delimiter, you should kindly request that
> I queue up that patch for stable, and why.  I handle networking
> stable submissions on my own.
>

I apologize. For some reason, I was under the impression that the rule applied 
to core networking and not driver-only changes. Will keep this in mind.

How should I proceed with this? Should I resubmit?

Also, I'm a little confused as to why my previous submissions to net with stable 
Cc'd were ok. E.g. commit 375679104ab3ccfd18dcbd7ba503734fb9a2c63a - "tg3: 
Expand 4g_overflow_test workaround to skb fragments of any size.". Did it slip 
by because I didn't have the < >?

Thanks,
Nithin.
