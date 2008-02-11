From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [BUG] bad address in twothirdsMD4Transform
Date: Mon, 11 Feb 2008 20:47:05 +0100
Message-ID: <47B0A639.2030306@gmail.com>
References: <47B0A220.8040400@gmail.com> <1202758960.12383.2.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:49980 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755490AbYBKTrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 14:47:10 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3898875fga.17
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 11:47:09 -0800 (PST)
In-Reply-To: <1202758960.12383.2.camel@cinder.waste.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2008 08:42 PM, Matt Mackall wrote:
>> BUG: unable to handle kernel paging request at ffff8102366213f8
>> IP: [<ffffffff803558f4>] twothirdsMD4Transform+0xc4/0x3b0
> 
> You should mention what kernel you're using. 

Kernel version is in the bug below modules and above registers.

> This bug is only in -mm
> (you didn't cc: Andrew), and it's fixed here:
> 
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24/2.6.24-mm1/hot-fixes/random-clean-up-checkpatch-complaints-fix.patch

I need to ask google first! Sorry.
