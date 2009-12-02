From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]atl1e:disable NETIF_F_TSO6 for hardware limit
Date: Wed, 02 Dec 2009 00:37:19 -0800 (PST)
Message-ID: <20091202.003719.233698986.davem@davemloft.net>
References: <1259723914457-git-send-email-jie.yang@atheros.com>
	<20091202.003151.77443093.davem@davemloft.net>
	<72981EBCFD196144B7C6999B9FC34A9A494C6DABC3@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, 558426@bugs.debian.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jie.Yang@Atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754859AbZLBIhP@vger.kernel.org>
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A494C6DABC3@SHEXMB-01.global.atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jie Yang <Jie.Yang@Atheros.com>
Date: Wed, 2 Dec 2009 16:34:18 +0800

> On Wednesday, December 02, 2009 4:32 PM
> David Miller <davem@davemloft.net> wrote:
>>
>> From: <jie.yang@atheros.com>
>> Date: Wed, 2 Dec 2009 11:18:34 +0800
>>
>> > From: Jie Yang <jie.yang@atheros.com>
>> >
>> > For hardware limit to support TSOV6, just disable this feature
>> > Signed-off-by: Jie Yang <jie.yang@atheros.com>
>>
>> Shouldn't we be applying this to net-2.6 since it's a bug fix?
>>
> oh, It should applying to net-2.6.

Great, that's where I've applied it.

Thanks.
