From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] tipc: fix a slab object leak
Date: Wed, 1 Apr 2015 11:16:12 +0800
Message-ID: <551B62FC.8030303@windriver.com>
References: <1427852570-25210-1-git-send-email-ying.xue@windriver.com> <20150331.231309.610369858855748160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59680 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbDADQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 23:16:42 -0400
In-Reply-To: <20150331.231309.610369858855748160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2015 11:13 AM, David Miller wrote:
> This bug exists in 'net', so that's where I'm applying it.
> 
> Can you please target your patches properly, I shouldn't be
> doing this kind of work for you.

Sure, I will recreate the patch targeted at "net" tree.

Thanks,
Ying
