From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and
 whitespace cleanups
Date: Tue, 05 Jun 2012 14:37:01 -0700 (PDT)
Message-ID: <20120605.143701.1108358650543335569.davem@davemloft.net>
References: <4FCD9F15.2050605@computer.org>
	<20120605.051437.1378262604943296071.davem@davemloft.net>
	<4FCDE447.3030103@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879Ab2FEVhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 17:37:05 -0400
In-Reply-To: <4FCDE447.3030103@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Tue, 05 Jun 2012 12:49:43 +0200

> On 06/05/2012 11:14 AM, David Miller wrote:
>> From: Jan Ceuleers <jan.ceuleers@computer.org>
>> Date: Tue, 05 Jun 2012 07:54:29 +0200
>> 
>>> So your build environment happens to be one of powerpc, alpha or mips,
>>> does it?
>> 
>> No, I get those errors you posted too.
>> 
>> But like I said, you simply IGNORE THEM, and look for newly introduced
>> errors and warnings.
> 
> David,
> 
> The error I quoted was a fatal error, meaning that compilation did not
> proceed beyond the point to which the error pertained (inclusion of a

I know it's a fatal error.

I'm saying IGNORE it.  I get it TOO!

You look at what it outputs before your changes, and then you run it
again after your changes and see if anything NEW shows up.

That's how I found your typo.
