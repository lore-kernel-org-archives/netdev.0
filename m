From: Philp Prindeville <philipp@redfish-solutions.com>
Subject: Re: [PATCH v1 1/1] pppoe: l2tp: the PPPOX_CONNECTED should be used
 with bit operation
Date: Thu, 18 Aug 2016 08:17:05 -0600
Message-ID: <f85455c2-9f78-c1e2-8570-84eb70baee23@redfish-solutions.com>
References: <1471485543-13149-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gfree.wind@gmail.com
To: fgao@48lvckh6395k16k5.yundunddos.com, mostrows@earthlink.net,
	jchapman@katalix.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:37704 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767002AbcHROTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 10:19:12 -0400
In-Reply-To: <1471485543-13149-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: Philip Prindeville <philipp@redfish-solutions.com>


On 08/17/2016 07:59 PM, fgao@48lvckh6395k16k5.yundunddos.com wrote:
> From: Gao Feng<fgao@ikuai8.com>
>
> There are some codes in pppoe and l2tp which use the PPPOX_CONNECTED
> as the value including assignment and condition check.
> They should keep consistent with other codes.
>
> Signed-off-by: Gao Feng<fgao@ikuai8.com>
