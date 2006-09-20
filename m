From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: process tx pause frames.
Date: Wed, 20 Sep 2006 17:49:41 -0400
Message-ID: <4511B775.4020607@pobox.com>
References: <20060906124447.642940bd@localhost.localdomain>	<45056102.2010408@pobox.com> <20060919141308.7e52b7d0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:3821 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932155AbWITVtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 17:49:43 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060919141308.7e52b7d0@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch already is in 2.6.17 stable, but the bigger version was pushed
> off till 2.6.19. Here is a less intrusive version that needs to go into 2.6.18
> (or I'll end up sending it for 2.6.18.1). The driver was telling the
> GMAC to flush (not process) pause frames. Manually disabling pause wasn't
> working because of problems in the setup.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

You'll need to send this to stable@kernel.org...

	Jeff



