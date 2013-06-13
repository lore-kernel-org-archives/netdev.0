From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net/core: Add VF link state control
Date: Thu, 13 Jun 2013 13:19:42 +0300
Message-ID: <51B99CBE.5070907@mellanox.com>
References: <1371024728-31790-1-git-send-email-ogerlitz@mellanox.com> <1371024728-31790-2-git-send-email-ogerlitz@mellanox.com> <20130613.024110.843518428947760865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>,
	<ronye@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:42128 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756194Ab3FMKTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 06:19:47 -0400
In-Reply-To: <20130613.024110.843518428947760865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/06/2013 12:41, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Wed, 12 Jun 2013 11:12:06 +0300
>
>> + * 			 * IFLA_VF_LINK_STATE_AUTO which equals zero
>> + * 			 */
> Please get rid of those leading "*" characters.
sure, done
