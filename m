From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 net-next 2/4] ixgbe: Remove driver specific fdb handlers.
Date: Fri, 01 Mar 2013 14:22:36 -0800
Message-ID: <51312A2C.5030509@intel.com>
References: <1362151906-20993-1-git-send-email-vyasevic@redhat.com> <1362151906-20993-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gregory Rose <gregory.v.rose@intel.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4235 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751619Ab3CAWWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 17:22:48 -0500
In-Reply-To: <1362151906-20993-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2013 7:31 AM, Vlad Yasevich wrote:
> Remove driver specific fdb handlers since they are the same
> as the default ones.
>
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Gregory Rose <gregory.v.rose@intel.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   42 +------------------------
>   1 files changed, 1 insertions(+), 41 deletions(-)
                                       ^^^^^^^^^^^^^^^^
nice.

Acked-By: John Fastabend <john.r.fastabend@intel.com>
