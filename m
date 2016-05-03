From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv2 bluetooth-next 00/10] 6lowpan: introduce basic
 6lowpan-nd
Date: Tue, 03 May 2016 16:07:37 -0400 (EDT)
Message-ID: <20160503.160737.1681209955436308203.davem@davemloft.net>
References: <D212A5BF-A414-403B-A409-1F8C2D279883@holtmann.org>
	<870fdf5f-82ed-b621-a8d5-625bf9d81d0d@stressinduktion.org>
	<58926844-0338-4D63-A5B6-DB0EBE903A0E@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <58926844-0338-4D63-A5B6-DB0EBE903A0E-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Date: Mon, 2 May 2016 16:17:41 -0700

>> My proposal would be that the IPv6 patches go via net-next to reduce
>> merge conflicts with maybe upcoming changes. If they are split up, they
>> seem very much self contained and easy to review. The rest seems to be
>> also very much self contained and can go in via bluetooth-next, then.
>> What do you think?
>
> I am actually fine with having this all go via net-next. We only
> have driver patches pending in bluetooth-next for the next merge
> window. Which means I can just pull net-next back into
> bluetooth-next at any time.

Ok, just resubmit the series explicitly targetting net-next then.

Thanks.
