From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sun, 28 Apr 2013 11:40:26 +0200
Message-ID: <20130428094026.GB4540@electric-eye.fr.zoreil.com>
References: <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
 <20130426134415.GS1366@pengutronix.de>
 <20130426.143309.1011152996477262852.davem@davemloft.net>
 <20130427090545.GY1366@pengutronix.de>
 <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
 <20130427120619.GA26097@electric-eye.fr.zoreil.com>
 <CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
 <20130427191600.GA30373@electric-eye.fr.zoreil.com>
 <CAHrpEqRnWXV7jC+QuQe+chiEJCXOkmOz1tEdna2SPfPBQ2E=1Q@mail.gmail.com>
 <CAHrpEqQeOx1HwSP6URtFM_0U+1a0e==Td3SOcA90Tbxadx-0cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49386 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420Ab3D1Jkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 05:40:46 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqQeOx1HwSP6URtFM_0U+1a0e==Td3SOcA90Tbxadx-0cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Li <lznuaa@gmail.com> :
[...]
> I just send out a patch to try to fix your problem.
> Can you help test it in your sit?

I don't have the required hardware.

But I can find bugs while the napi-is-too-hard-please-do-proper-project-mgmt
squad watches elsewhere. :o)

-- 
Ueimor
