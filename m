From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 16:08:05 +0530
Message-ID: <OFBB992ED6.6AEB3511-ON652573D9.003AC1C3-652573D9.003A6B6F@in.ibm.com>
References: <Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:34768 "EHLO
	e28esmtp04.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750767AbYAWKjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 05:39:43 -0500
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m0NAdcEf001707
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 16:09:38 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NAdcZk770244
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 16:09:38 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m0NAdcdU027303
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 10:39:38 GMT
In-Reply-To: <Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ilpo.jarvinen@helsinki.fi wrote on 01/23/2008 03:23:24 PM:

> > There were couple of patch apply failures in .c files which I fixed by
> > hand.
> > But when compiling, I got these errors (I am using DM's 2.6.24-rc7
kernel,
> > net-2.6.25.git):
>
> Well, that's annoying, you didn't mention net-2.6.25 back then, it sure
> is incompatible with it like already the patch title said... :-)

I did mention that in my first mail:

"Bits are unmodified 2.6.24-rc7 bits downloaded today (Jan 23rd)".

I tried it hoping it would not change a lot, but it didn't work
obviously :)

> ...This is either due to mismerge or due your modifications.

Again, it was due to wrong patch bits (to reiterate, I am using
unmodified bits without any modifications), but let's move ahead.
Your patch in this mail applied cleanly for me, and I am compiling
now.

- KK

