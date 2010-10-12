From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tbf/htb qdisc limitations
Date: Tue, 12 Oct 2010 15:17:18 -0700
Message-ID: <4CB4DE6E.7030802@hp.com>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>	<4CB1A22B.9090701@gmail.com>	<AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>	<20101012101022.GA8578@ff.dom.local>	<AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com> <20101012215932.GA1945@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:41185 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab0JLWRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 18:17:22 -0400
In-Reply-To: <20101012215932.GA1945@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>my burst problem is the only semi-legitimate motivation i can think
>>of. the only other possible motivations i can imagine are setting
>>"limit" to buffer more than 4GB of packets and setting "rate" to
>>something more than 32 gigabit; both of these seem kind of dubious. is
>>there something else you had in mind?
> 
> 
> No, mainly 10 gigabit rates and additionally 64-bit stats.

Any issue for bonded 10 GbE interfaces?  Now that the IEEE have ratified (June) 
how far out are 40 GbE interfaces?  Or 100 GbE for that matter.

rick jones
