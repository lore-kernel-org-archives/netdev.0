From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/3] net: bpf: consolidate JIT binary allocator
Date: Mon, 08 Sep 2014 08:09:31 +0200
Message-ID: <540D481B.3070202@redhat.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com> <1409996567-2170-2-git-send-email-dborkman@redhat.com> <20140907.161543.2206530539028176158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, edumazet@google.com,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982AbaIHGJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 02:09:40 -0400
In-Reply-To: <20140907.161543.2206530539028176158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2014 01:15 AM, David Miller wrote:
...
> Both -2 and ~1 are the same value.

Argh, you are right, sorry. I have removed that paragraph
from the commit message and resent the set. Thanks!
