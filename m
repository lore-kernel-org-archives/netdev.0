From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v1 resent] net: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
Date: Mon, 16 Nov 2009 09:01:03 -0500
Message-ID: <4B015B1F.3000604@gmail.com>
References: <4B00A858.8000705@gmail.com> <20091115.205442.77893528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:60820 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbZKPOBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:01:00 -0500
In-Reply-To: <20091115.205442.77893528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I already applied this patch to net-next-2.6, there is no need
> to resend it.
> 
Cool, there wasn't your usual "applied" response to the list, so the
instructions say send again after waiting (5 days in this case), as it
might have been overlooked.

'git fetch' followed by 'git rebase origin/master' re-applies my patches
locally, but doesn't inform me that this patch has already been applied,
it just handles it silently....

I've found the log, it's commit bee7ca9ec03a26676ea2b1c28dc4039348eff3e1

Thanks!
