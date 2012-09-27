From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH] qlcnic - Fix scheduling while atomic bug
Date: Thu, 27 Sep 2012 16:13:49 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA877447F451C@AVEXMB1.qlogic.org>
References: <20120925175212.GA1324@fedora-17-guest.blr.amer.dell.com>
 <20120927.182133.1396850191643578552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>,
	"Narendra_K@Dell.com" <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.207] ([213.199.154.207]:32299 "EHLO
	am1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754952Ab2I0XRq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 19:17:46 -0400
In-Reply-To: <20120927.182133.1396850191643578552.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
>Sent: Thursday, September 27, 2012 3:22 PM
>To: Narendra_K@Dell.com
>Cc: netdev; Sony Chacko; Jitendra Kalsaria; john.r.fastabend@intel.com
>Subject: Re: [PATCH] qlcnic - Fix scheduling while atomic bug
>
>
>Is it really the case that not one Qlogic person feels like ACK'ing
>this patch that fixes an obvious bug in their driver for 2 full days?
>
>For real?

Definitely it fixes an obvious bug and also an good patch but it took little longer to test it before I ack back.

