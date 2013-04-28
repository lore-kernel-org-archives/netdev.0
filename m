From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Sun, 28 Apr 2013 18:03:06 +0800
Message-ID: <CAHrpEqRY0g-0RGdPBKKMto9RhQJFoPG9PrF6b_bDPEnzb40A9A@mail.gmail.com>
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
	<20130428094026.GB4540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36996 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab3D1KDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 06:03:08 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so4211148wey.19
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 03:03:07 -0700 (PDT)
In-Reply-To: <20130428094026.GB4540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/28 Francois Romieu <romieu@fr.zoreil.com>:
> Frank Li <lznuaa@gmail.com> :
> [...]
>> I just send out a patch to try to fix your problem.
>> Can you help test it in your sit?
>
> I don't have the required hardware.
>
> But I can find bugs while the napi-is-too-hard-please-do-proper-project-mgmt
> squad watches elsewhere. :o)

Sorry, what's your means?

>
> --
> Ueimor
