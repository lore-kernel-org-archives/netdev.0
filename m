From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] TI DaVinci EMAC: Minor macro related updates
Date: Mon, 26 Oct 2009 23:07:22 +0100
Message-ID: <20091026220722.GA23415@game.jcrosoft.org>
References: <1254428719-13960-1-git-send-email-chaithrika@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	davinci-linux-open-source@linux.davincidsp.com
To: Chaithrika U S <chaithrika@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 17.mail-out.ovh.net ([91.121.30.212]:53357 "HELO
	17.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753722AbZJZWdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 18:33:33 -0400
Content-Disposition: inline
In-Reply-To: <1254428719-13960-1-git-send-email-chaithrika@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16:25 Thu 01 Oct     , Chaithrika U S wrote:
> Use BIT for macro definitions wherever possible, remove
> unused and redundant macros.
> 
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>
> ---
> Applies to Linus' kernel tree
do you plan to send a new version soon?

as the current DaVinci EMAC does not build on the v2.6.32-rc5

Best Regards,
J.
