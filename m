From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Fix deadlock in tg3_change_mtu()
Date: Thu, 06 Feb 2014 17:10:49 -0800 (PST)
Message-ID: <20140206.171049.1186323575659109391.davem@davemloft.net>
References: <1391724785-13562-1-git-send-email-nsujir@broadcom.com>
	<20140206.165448.1676259324527494823.davem@davemloft.net>
	<52F43219.8010809@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.vrabel@citrix.com,
	stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <52F43219.8010809@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nithin Nayak Sujir <nsujir@broadcom.com>
Date: Thu, 6 Feb 2014 17:08:41 -0800

> I apologize. For some reason, I was under the impression that the rule
> applied to core networking and not driver-only changes. Will keep this
> in mind.
> 
> How should I proceed with this? Should I resubmit?

You don't need to resubmit.

> Also, I'm a little confused as to why my previous submissions to net
> with stable Cc'd were ok. E.g. commit
> 375679104ab3ccfd18dcbd7ba503734fb9a2c63a - "tg3: Expand
> 4g_overflow_test workaround to skb fragments of any size.". Did it
> slip by because I didn't have the < >?

I didn't catch them at the time, that's all.  I process hundreds of
patches a day.
