From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls
 (after pci_enable_device) fails
Date: Tue, 29 May 2012 19:24:38 -0400 (EDT)
Message-ID: <20120529.192438.1186076504142998357.davem@davemloft.net>
References: <1338333250-11974-1-git-send-email-devendra.aaru@gmail.com>
	<20120529.191810.2141710455829509698.davem@davemloft.net>
	<CAHdPZaMfSKRzT4MN-5g3c1bOah4CB80aWyVhGKu1Z5AXTj2uTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189Ab2E2XYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 19:24:43 -0400
In-Reply-To: <CAHdPZaMfSKRzT4MN-5g3c1bOah4CB80aWyVhGKu1Z5AXTj2uTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "devendra.aaru" <devendra.aaru@gmail.com>
Date: Wed, 30 May 2012 04:52:08 +0530

> Hello David,
> 
> On Wed, May 30, 2012 at 4:48 AM, David Miller <davem@davemloft.net> wrote:
>>
>> Please number your patches so that there is no ambguity as to what
>> order the patches should be applied.
>>
>> That is especially important for patches like these two which make
>> changes in the same areas of code.
> 
> OK, so may i put these two changes into one and send it? or you want
> it to be two patches?

It's up to you.
