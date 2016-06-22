From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Wed, 22 Jun 2016 15:24:08 -0400 (EDT)
Message-ID: <20160622.152408.1343255136815304537.davem@davemloft.net>
References: <20160621.042918.1782717212289281861.davem@davemloft.net>
	<CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
	<0dff6f22-3e43-f658-65ee-1c429823cc1f@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, tom@herbertland.com, netdev@vger.kernel.org,
	kernel-team@fb.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbcFVTYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 15:24:13 -0400
In-Reply-To: <0dff6f22-3e43-f658-65ee-1c429823cc1f@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 21 Jun 2016 22:06:01 -0600

> On 6/21/16 9:42 PM, Jerry Chu wrote:
>> Yes TOU may lower the bar for random hacks by Joe Random. But I'd
>> argue
>> no large organization would serious consider or dare deploy TCP stack
>> with random hacks.
> 
> There are userspace network stacks that have been around for years and
> widely deployed on devices that basically use Linux as the boot OS.

I'm not talking about TCP stacks that are trying to do things right.
