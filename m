From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Wed, 16 May 2007 22:09:16 -0400
Message-ID: <464BB94C.1020103@gentoo.org>
References: <20070430142349.79754c1b@freekitty>	<46374784.7010401@gentoo.org>	<20070510090010.4c6b8589@freepuppy>	<464734F1.2020103@gentoo.org> <20070514120206.5181839e@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org, Francois SIMOND <curio@free.fr>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:33394 "EHLO
	smtp151.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880AbXEQCKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 22:10:21 -0400
In-Reply-To: <20070514120206.5181839e@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It looks like these users aren't using MSI?

Possible. Want me to find out?

I just ask as I note yesterday's -stable patch where you remove the 
#ifdef completely. Is that going to go upstream into 2.6.22 or do you 
want to continue pursuing the DMI matching path?

Thanks,
Daniel

