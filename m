From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Support specifying the network namespace upon
 device creation.
Date: Tue, 03 Nov 2009 02:05:55 -0800 (PST)
Message-ID: <20091103.020555.156050455.davem@davemloft.net>
References: <m1eioggeux.fsf@fess.ebiederm.org>
	<4AEFF7BB.4090301@gmail.com>
	<m1ws28ey3k.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbZKCKFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:05:30 -0500
In-Reply-To: <m1ws28ey3k.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Nov 2009 01:50:23 -0800

> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>
>> Very nice, with only one long line you could wrap differently.
> 
> Say again?  Was that very nice with respect to the rest of the patch?
> Or sarcasm because I overlooked this wrap at 80 columns
> opportunity in ipgre?

It can also be argued that for functions, wrapping the args is
worse because it makes grep output less useful.  In fact that's,
I believe, Linus's most recent recommendation in this area :)
