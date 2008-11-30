From: Roland Dreier <rdreier@cisco.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sun, 30 Nov 2008 09:31:22 -0800
Message-ID: <adabpvxazo5.fsf@cisco.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
	<20081128135419.GH32518@solarflare.com>
	<5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
	<20081129173442.GI32518@solarflare.com> <adamyfib173.fsf@cisco.com>
	<Pine.LNX.4.64.0811291853010.12483@t2.domain.actdsltmp>
	<5d96567b0811292325j39f39a9ew343b430de72453d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trent Piepho" <tpiepho@freescale.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Raz <raziebe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:17545 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbYK3RbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 12:31:24 -0500
In-Reply-To: <5d96567b0811292325j39f39a9ew343b430de72453d4@mail.gmail.com>
	(Raz's message of "Sun, 30 Nov 2008 09:25:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > I tested it both on PCIE2 and PCIE1 . same results.

if the NIC is not capable of PCIe 2.0 (5 GT/sec) then it wouldn't make a
difference.

 - R.
