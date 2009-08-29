From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: switch to seq_file
Date: Sat, 29 Aug 2009 10:09:34 +0200
Message-ID: <4A98E23E.2010009@hartkopp.net>
References: <20090828195721.GD15123@x200.localdomain> <20090829.002112.160212045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:42341 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbZH2IJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 04:09:39 -0400
In-Reply-To: <20090829.002112.160212045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Fri, 28 Aug 2009 23:57:21 +0400
> 
>> create_proc_read_entry() is going to be removed soon.
>>
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> Applied to net-next-2.6, thanks.

Good to see that it's obviously ok for Dave ;-)

Many thanks for the effort, Alexey!
I'll do some additional testing when i'm back in the office on Monday.

Tnx & best regards,
Oliver

