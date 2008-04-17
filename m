From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to the cpm_muram
 implementation
Date: Thu, 17 Apr 2008 09:32:19 -0500
Message-ID: <48075F73.9060200@freescale.com>
References: <20080416182214.GA20056@polina.dev.rtsoft.ru> <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net> <20080417141043.GA21793@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Li Yang <LeoLi@freescale.com>, avorontsov@ru.mvista.com,
	Kumar Gala <galak@kernel.crashing.org>,
	linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:50992 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756000AbYDQOdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 10:33:08 -0400
In-Reply-To: <20080417141043.GA21793@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:

> And then change it again when marketing decides that CPM4 will be called
> something other than QE2? :-P

I agree with Scott.  The QE is really just CPM3.

-- 
Timur Tabi
Linux kernel developer at Freescale
