From: Massimo Cetra <mcetra@navynet.it>
Subject: Re: [RFC PATCH] bridge: netfilter: fix skb->nf_bridge NULL panic
 in br_nf_forward_finish
Date: Tue, 10 Jul 2012 08:58:17 +0200
Message-ID: <4FFBD289.7050909@navynet.it>
References: <1341584394.4789.34.camel@chief-river-32> <4FFAA3CE.1090504@navynet.it> <CAF1ivSZBMWYc5iKxhX5d_ykkMD4LauFP9M10dBwfmqvpYj=pHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host180-6-static.238-77-b.business.telecomitalia.it ([77.238.6.180]:59641
	"EHLO mailhub2.navynet.it" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751928Ab2GJG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 02:58:48 -0400
In-Reply-To: <CAF1ivSZBMWYc5iKxhX5d_ykkMD4LauFP9M10dBwfmqvpYj=pHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2012 14:00, Lin Ming wrote:

>> i spent a couple of days trying to figure out how to reproduce but you were
>> quicker and smarter than me.
>
> Could you also test it ? :-)
>

Of course.

I have already installed a 3.5-rc and a 3.2.22 with this patch and, by 
now, i see no problems.

I'm only waiting a couple of days before reporting, to be sure the issue 
is gone.

Massimo
