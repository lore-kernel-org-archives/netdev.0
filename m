From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Tue, 21 Jun 2016 22:06:01 -0600
Message-ID: <0dff6f22-3e43-f658-65ee-1c429823cc1f@cumulusnetworks.com>
References: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
 <20160619.200741.1114304127682357737.davem@davemloft.net>
 <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
 <20160621.042918.1782717212289281861.davem@davemloft.net>
 <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kernel-team@fb.com
To: Jerry Chu <hkchu@google.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38227 "EHLO
	mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcFVEGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 00:06:03 -0400
Received: by mail-it0-f46.google.com with SMTP id h190so30691275ith.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 21:06:03 -0700 (PDT)
In-Reply-To: <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/16 9:42 PM, Jerry Chu wrote:
> Yes TOU may lower the bar for random hacks by Joe Random. But I'd argue
> no large organization would serious consider or dare deploy TCP stack
> with random hacks.

There are userspace network stacks that have been around for years and 
widely deployed on devices that basically use Linux as the boot OS.
