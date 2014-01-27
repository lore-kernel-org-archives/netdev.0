From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next 0/7] qlcnic: Refactoring and enhancements for
 all adapters.
Date: Mon, 27 Jan 2014 22:04:17 +0000
Message-ID: <52E6D7E1.90204@citrix.com>
References: <cover.1390491376.git.himanshu.madhani@qlogic.com> <20140123.161437.1632835743136251770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>, <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:38352 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343AbaA0WEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 17:04:20 -0500
In-Reply-To: <20140123.161437.1632835743136251770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/01/14 00:14, David Miller wrote:
> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> Date: Thu, 23 Jan 2014 17:18:27 -0500
>
>> This patch series contains following patches.
>>
>> o Enhanced debug data collection when we are in Tx-timeout situation.
>> o Enhanced MSI-x vector calculation for defualt load path as well
>>    as for TSS/RSS ring change path.
>> o Refactored interrupt coalescing code for all adapters.
>> o Refactored interrupt handling as well as cleanup of poll controller
>>    code patch for all adapters.
>> o changed rx_mac_learn type to boolean.
>>
>> Please apply to net-next.
>
> Series applied, thanks.

Not that I reject fame, but the commit message contains my name as 
sign-off, while I've never seen a bit of that code :)

Zoli
