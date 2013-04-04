From: Sagi Grimberg <sagig@mellanox.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Thu, 4 Apr 2013 19:08:25 +0300
Message-ID: <515DA579.3050006@mellanox.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com> <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com> <515DA342.5020503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <amirv@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:53189 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762397Ab3DDQIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:08:36 -0400
In-Reply-To: <515DA342.5020503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2013 6:58 PM, John Fastabend wrote:
> On 4/4/2013 7:26 AM, Or Gerlitz wrote:
>> From: Sagi Grimberg <sagig@mellanox.com>
>>
>> The lldpad daemon queries the driver caps via the getcaps and getstate
>> routines. Added the prpoer dbcnl_ops entries to support that.
>>
>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>
> Does lldpad work now with the mlx4_en driver?
>
> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>

Yes.

-Sagi
