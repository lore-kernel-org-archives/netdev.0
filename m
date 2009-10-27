From: "Chaithrika U S" <chaithrika@ti.com>
Subject: RE: [PATCH] TI DaVinci EMAC: Minor macro related updates
Date: Tue, 27 Oct 2009 09:27:42 +0530
Message-ID: <040901ca56b9$a2786c60$e7694520$@com>
References: <1254428719-13960-1-git-send-email-chaithrika@ti.com> <20091026220722.GA23415@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<davinci-linux-open-source@linux.davincidsp.com>
To: "'Jean-Christophe PLAGNIOL-VILLARD'" <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:54577 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbZJ0EAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 00:00:11 -0400
In-Reply-To: <20091026220722.GA23415@game.jcrosoft.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2009 at 03:37:22, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 16:25 Thu 01 Oct     , Chaithrika U S wrote:
> > Use BIT for macro definitions wherever possible, remove
> > unused and redundant macros.
> > 
> > Signed-off-by: Chaithrika U S <chaithrika@ti.com>
> > ---
> > Applies to Linus' kernel tree
> do you plan to send a new version soon?
> 
> as the current DaVinci EMAC does not build on the v2.6.32-rc5
> 
> Best Regards,
> J.
> 

DaVinci EMAC builds and work fine on Linus' tree and DaVinci GIT tree.
Can you please provide more info regarding the errors you are seeing?

Regards, 
Chaithrika


