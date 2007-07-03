From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: Re: [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
Date: Tue, 03 Jul 2007 14:36:09 -0700
Message-ID: <468AC149.4020205@sun.com>
References: <200706291330.37070.yinghai.lu@sun.com>
 <20070703115840.e05a0f47.akpm@linux-foundation.org>
Reply-To: Yinghai.Lu@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andi Kleen <ak@suse.de>, Greg KH <greg@kroah.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:33569 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098AbXGCVda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 17:33:30 -0400
In-reply-to: <20070703115840.e05a0f47.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Fri, 29 Jun 2007 13:30:36 -0700
> Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:
> 
>> [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
> 
> Please copy netdev@vger.kernel.org on net patches.
> 
> It might help to edit code in an 80-col xterm.
> 
> Please run scritps/checkpatch.pl across all your diffs.  Its suggestions
> are by no means compulsory, but they do provide things for you to check up
> and and have a think about, thanks.

I see. later.

Thanks

Yinghai Lu
