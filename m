From: venkat venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: [Patch net] rds: limit the size allocated by rds_message_alloc()
Date: Mon, 04 Mar 2013 08:43:03 -0600
Message-ID: <5134B2F7.3000207@oracle.com>
References: <1362363491-24501-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	Dave Jones <davej@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28344 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758011Ab3CDOnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 09:43:11 -0500
In-Reply-To: <1362363491-24501-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 3/3/2013 8:18 PM, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
>
> Dave Jones reported the following bug:
>
> "When fed mangled socket data, rds will trust what userspace gives it,
> and tries to allocate enormous amounts of memory larger than what
> kmalloc can satisfy."
>
> Reported-by: Dave Jones <davej@redhat.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
Acked-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
