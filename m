From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] net/tcp: Fix tcp memory limits initialization when !CONFIG_SYSCTL
Date: Mon, 30 Jan 2012 15:17:53 +0400
Message-ID: <4F267C61.9090802@parallels.com>
References: <20120127142246.GA22318@elte.hu> <4F22B634.2020007@parallels.com> <4F22D05A.8030604@parallels.com> <20120127.162823.1960229872591588915.davem@davemloft.net> <4F231703.4040803@parallels.com> <20120128115028.GA14020@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120128115028.GA14020@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2012 03:50 PM, Ingo Molnar wrote:
>
> ok, the patch works fine - in the tested version i've renamed
> the function and cleaned up the changelog a bit, see the final
> patch below.
>
> Thanks,
>
> 	Ingo
>
Thank you Ingo.

will submit this patch now, then.
