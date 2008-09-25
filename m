From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates for .28
Date: Thu, 25 Sep 2008 13:38:21 -0400
Message-ID: <48DBCC8D.7060709@garzik.org>
References: <20080924230710.GA22856@havoc.gtf.org> <20080925085556.4c430028@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sebastien Dugue <sebastien.dugue@bull.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, torvalds@gtf.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Klein <osstklei@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55883 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822AbYIYRic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 13:38:32 -0400
In-Reply-To: <20080925085556.4c430028@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastien Dugue wrote:
>   Hi Jeff,
> 
> On Wed, 24 Sep 2008 19:07:10 -0400 Jeff Garzik <jeff@garzik.org> wrote:
> 
> 
>> Sebastien Dugue (2):
>>       ehea: fix phyp debugging typo
> 
> 
>>       ehea: fix mutex and spinlock use
> 
>         ^^^^^^
> 
>   That last one was NACKed by Thomas Klein (http://lkml.org/lkml/2008/9/15/81)
> who asked for it to be reverted.


David, please revert 2eefbd63d0c85daa1317636474c226e236beba81 by request 
of author, maintainer, and maintainer's maintainer :)

	Jeff




