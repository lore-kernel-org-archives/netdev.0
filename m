From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [1/8,RFC] CAIF Protocol Stack
Date: Tue, 6 Oct 2009 21:00:39 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902ED6712@eseldmw101.eemea.ericsson.se>
References: <1253727026-10233-1-git-send-email-sjur.brandeland@stericsson.com> <4AC9ECD4.70602@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>
To: "Stefano Babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:52620 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964AbZJFTCW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:02:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4AC9ECD4.70602@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefano.
Thank you for useful feedback!
I'm planning to send out a new patch-set sometime this week.

Stefano Babic wrote:
> [snip]
> +union caif_action {
>...=20
> It seems this structure is defined twice (here and in caif_actions.h)

I have cleaned this up, caif_action is now only defined in caif_actions=
=2Eh


BR/Sjur Br=E6ndeland
