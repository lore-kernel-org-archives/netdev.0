From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v13 0/6] flexcan: Add support for powerpc flexcan (freescale p1010)
Date: Tue, 18 Oct 2011 00:44:07 -0500
Message-ID: <16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org>
References: <1313551944-28603-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38895 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754018Ab1JRFoc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 01:44:32 -0400
In-Reply-To: <1313551944-28603-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 16, 2011, at 10:32 PM, Robin Holt wrote:

> David,
> 
> The following set of patches have been reviewed by the above parties and
> all comments have been integrated.  Although the patches stray from the
> drivers/net/can directory, the diversions are related to changes for
> the flexcan driver.
> 
> The patch set is based upon your net-next-2.6 tree's commit 6c37e46.
> 
> Could you please queue these up for the next appropriate push to Linus'
> tree?
> 
> Thanks,
> Robin Holt

Robin,

Do you remember why we went with just 'fsl,p1010-flexcan' as the device tree compatible?  Do we feel the flex can on P1010 isn't the same as on MPC5xxx? or the ARM SoCs?

- k