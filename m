From: Toyo Abe <tabe@miraclelinux.com>
Subject: Re: [GIT PULL net-next-2.6] IPv6 Updates
Date: Thu, 03 Jul 2008 01:46:58 +0900
Message-ID: <486BB102.7040409@miraclelinux.com>
References: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>	<486B2208.2000104@miraclelinux.com> <20080702195934.754349fb.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:12960 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbYGBQq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 12:46:56 -0400
In-Reply-To: <20080702195934.754349fb.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chinen-san,

Mitsuru Chinen wrote:
>> I don't see why you set 1 as a default, so far.
>> Any concerns on setting >1 as a default?
> 
> You may want to read this discussion:
> - Linux IPv6 DAD not full conform to RFC 4862 ?
>   http://www.spinics.net/lists/netdev/msg52027.html
> 
> The conclusion is:
>   http://www.spinics.net/lists/netdev/msg52095.html

Now I see. Thank you for pointing.

Regards,
-toyo
