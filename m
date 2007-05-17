From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Wed, 16 May 2007 22:58:24 -0400
Message-ID: <464BC4D0.9020008@garzik.org>
References: <20070430142349.79754c1b@freekitty>	<46374784.7010401@gentoo.org> <20070510090010.4c6b8589@freepuppy>	<464734F1.2020103@gentoo.org> <20070514120206.5181839e@freepuppy> <464BB94C.1020103@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, stable@kernel.org,
	Francois SIMOND <curio@free.fr>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35098 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758501AbXEQC63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 22:58:29 -0400
In-Reply-To: <464BB94C.1020103@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Stephen Hemminger wrote:
>> It looks like these users aren't using MSI?
> 
> Possible. Want me to find out?
> 
> I just ask as I note yesterday's -stable patch where you remove the 
> #ifdef completely. Is that going to go upstream into 2.6.22 or do you 
> want to continue pursuing the DMI matching path?

Stephen has some sky2 patches I need to push.  I accidentally filed them 
until 'Pending: SATA', and they got missed in my most recent net driver 
push.

	Jeff



