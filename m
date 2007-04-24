From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Tue, 24 Apr 2007 17:14:28 +0900
Message-ID: <462DBC64.9070102@bx.jp.nec.com>
References: <462605DC.2080804@bx.jp.nec.com>	<462609D1.50300@bx.jp.nec.com>	<20070419210813.a599c54f.akpm@linux-foundation.org>	<46288D11.4000801@bx.jp.nec.com> <20070420111526.01ad7f4c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:58089 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbXDXIPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 04:15:41 -0400
In-Reply-To: <20070420111526.01ad7f4c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, 20 Apr 2007 18:51:13 +0900
> Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> 
>>> I started to do some cleanups and fixups here, but abandoned it when it was
>>> all getting a bit large.
>>>
>>> Here are some fixes against this patch:
>> I'm going to fix my patches by following your reviews and send new patches 
>> on the LKML and the netdev ML in a few days.
>>
> 
> Well..  before you can finish this work we need to decide upon what the
> interface to userspace will be.
> 
> - The miscdev isn't appropriate
> 

Why isn't miscdev appropriate? 
We just shouldn't use miscdev for networking conventionally?

-- 
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com





