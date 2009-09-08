From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] add vif using local interface index (was Re: multicast routing and multiple interfaces with same IP)
Date: Tue, 8 Sep 2009 16:03:10 +0300
Message-ID: <200909081603.10481.opurdila@ixiacom.com>
References: <1b9338490909080021n6dcac8e8x40e7c4676df74e29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Ilia K." <mail4ilia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:4148 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753755AbZIHNFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 09:05:37 -0400
In-Reply-To: <1b9338490909080021n6dcac8e8x40e7c4676df74e29@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 08 September 2009 10:21:18 you wrote:

> I'm just  used to place braces either on both if/else parts or none,
> but since you think this breaks linux code style, I've removed braces.
> Another coding style issues reported by checkpatch.pl are fixed too.
> 

One more thing :)

Can you please re-send the mail in "submission ready" format:
- subject line with [PATCH] and short summary of the change
- description of the change in the mail message 
- Signed-off-by line at the end of the description message

Here is an example: http://patchwork.ozlabs.org/patch/32684/

Thanks!
tavi
