From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] [V2] net: ipconfig: add declaration for ic_addrservaddr
Date: Fri, 10 Jun 2016 09:53:16 +0100
Message-ID: <83806a60-5186-13f4-bcd2-d44ac4673a6b@codethink.co.uk>
References: <1465494877-10552-1-git-send-email-ben.dooks@codethink.co.uk>
 <20160609.133535.1784019078497827547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:49663 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbcFJIxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 04:53:21 -0400
In-Reply-To: <20160609.133535.1784019078497827547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/16 21:35, David Miller wrote:
> From: Ben Dooks <ben.dooks@codethink.co.uk>
> Date: Thu,  9 Jun 2016 18:54:37 +0100
> 
>> The symbol ic_addrservaddr is not static, but has no declaration
>> to match so make it static to fix the following warning:
>>
>> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not declared. Should it be static?
>>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> 
> Your Subject line needs to be updated, you're not ading a declaration
> any more.

OOPS. Will fix and re-send thanks.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
