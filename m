From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V3 net-next 0/3] Control VF link state
Date: Sun, 16 Jun 2013 13:50:07 +0300
Message-ID: <51BD985F.80204@mellanox.com>
References: <1371118752-2314-1-git-send-email-ogerlitz@mellanox.com> <20130613.175128.633380066489526678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>,
	<ronye@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:40908 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755164Ab3FPKuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 06:50:13 -0400
In-Reply-To: <20130613.175128.633380066489526678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/06/2013 03:51, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu, 13 Jun 2013 13:19:09 +0300
>
>> These patches add API and implementation that lets the admin to configure the link
>> state of the VF / SRIOV  eSwitch vPORT. Basically, it has three states
>>
>> Auto - VF link state reflects the PF link state (default)
>>
>> Up - VF link state is up, traffic from VF to VF works even if
>> the actual PF link is down
>>
>> Down - VF link state is down, no traffic from/to this VF, can be of
>> use while configuring the VF
> Applied with trailing whitespace errors fixed in patch #1.
>
>

thanks, will double check that next time

Or.
