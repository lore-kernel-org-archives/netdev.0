From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: Remove more stack DMA
Date: Thu, 14 Jul 2016 13:42:28 -0700 (PDT)
Message-ID: <20160714.134228.1304083998111770957.davem@davemloft.net>
References: <1ff8c3e69b8d4f1ad717affa073b279a74ee4309.1468272497.git.luto@kernel.org>
	<20160712.104030.1596691470300748311.davem@davemloft.net>
	<CALCETrUUwBdjoznrot7+ufmbzzsC2SZL2g2zy_HjT82Q_AwM1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUUwBdjoznrot7+ufmbzzsC2SZL2g2zy_HjT82Q_AwM1Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 14 Jul 2016 13:21:46 -0700

> On Tue, Jul 12, 2016 at 10:40 AM, David Miller <davem@davemloft.net> wrote:
>> From: Andy Lutomirski <luto@kernel.org>
>> Date: Mon, 11 Jul 2016 14:30:28 -0700
>>
>>> DaveM, is it okay for this to go in via -tip?
>>
>> Sure.
> 
> Looks like the series that depends on this is getting delayed to 4.9.
> Could you queue this patch for net-next instead?

Can you just resubmit these instead of replying to each patch individually?
