From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Wed, 16 May 2007 23:21:24 -0400
Message-ID: <464BCA34.1010205@gentoo.org>
References: <20070430142349.79754c1b@freekitty>	<46374784.7010401@gentoo.org> <20070510090010.4c6b8589@freepuppy>	<464734F1.2020103@gentoo.org> <20070514120206.5181839e@freepuppy> <464BB94C.1020103@gentoo.org> <464BC4D0.9020008@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, stable@kernel.org,
	Francois SIMOND <curio@free.fr>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp141.iad.emailsrvr.com ([207.97.245.141]:41751 "EHLO
	smtp141.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbXEQDW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 23:22:28 -0400
In-Reply-To: <464BC4D0.9020008@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Stephen has some sky2 patches I need to push.  I accidentally filed them 
> until 'Pending: SATA', and they got missed in my most recent net driver 
> push.

Thanks, that clears it up, forgot to check netdev before asking. Looks 
like the 2.6.22 plans are to drop the machine detection, and enable 
88E8056 everywhere.

Daniel
