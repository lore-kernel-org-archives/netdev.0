From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 0/5 2.6.21-rc7] l2tp: introduce PPP over L2TP driver
Date: Mon, 23 Apr 2007 16:58:58 +0100
Message-ID: <462CD7C2.40104@katalix.com>
References: <200704231255.l3NCte3Y028365@quickie.katalix.com> <462CCBBC.1010009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:32933 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753971AbXDWP7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 11:59:01 -0400
In-Reply-To: <462CCBBC.1010009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My mistake. I'll reorder the patches and resubmit.

Patrick McHardy wrote:
> James Chapman wrote:
>> This patch set adds a driver for PPP over L2TP. Patches to follow.
>>
>> The following changes have been made since the previous version
>> submitted 23-MAR-07, addressing review comments received so far:-
>>
>> - Fold makefile changes into the patches that add new source files.
> 
> 
> The reason to do this was to keep the tree compiling at all stages,
> which this patchset still doesn't do. You should first add your changes
> to other files (like skb_queue_walk_safe, ppp headers, ...), then
> add the code that uses them.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

