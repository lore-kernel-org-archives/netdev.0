From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Fri, 03 Jun 2011 21:51:13 +0200
Message-ID: <4DE93B31.8040700@ahsoftware.de>
References: <4DE93422.3070000@ahsoftware.de> <1307129642.2600.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:57851 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755779Ab1FCTvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 15:51:21 -0400
In-Reply-To: <1307129642.2600.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Am 03.06.2011 21:34, schrieb Eric Dumazet:
>>
>> Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
>> should prevent, it introduces NULL a dereference.
>>
>
> I cant find this commit in known trees. Could you give the real commit
> id and its title ?

Sorry, I haven't seen that question at first. This is the real commit id 
as found in the stable tree for 2.6.39. The title of that commit is
"bridge: initialize fake_rtable metrics"

Regards,

Alexander
