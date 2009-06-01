From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [GIT]: Networking
Date: Mon, 01 Jun 2009 21:59:48 +0200
Message-ID: <4A243334.3020402@hartkopp.net>
References: <20090601.032500.54712490.davem@davemloft.net> <1243867942.3015.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:59781 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128AbZFAT7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 15:59:50 -0400
In-Reply-To: <1243867942.3015.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Dave,
> 
>> Things are really winding down, and the bug fix rate is down
>> to at best a trickle.  It might be time to do that final
>> release soon :-)
> 
> can you give me quick update on this pull request:
> 
> 	http://marc.info/?l=linux-netdev&m=124341070008320&w=2
> 
> Regards
> 
> Marcel

Just to make clear that this patch does not only fix a "lockdep warning":

Without this patch dialup networking via mobile phones via bluetooth does not
work anymore ...

Best regards,
Oliver

