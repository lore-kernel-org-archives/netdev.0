From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: SYN flooding on port 80 + DMAR:[DMA Write] faults
Date: Sun, 13 Mar 2016 01:11:55 +0100
Message-ID: <20160313001155.GA21952@electric-eye.fr.zoreil.com>
References: <56E4A30A.2060800@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42129 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbcCMAL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 19:11:57 -0500
Content-Disposition: inline
In-Reply-To: <56E4A30A.2060800@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toralf F=C3=B6rster <toralf.foerster@gmx.de> :
> Today my server (64 bit hardened Gentoo kernel) was faced a SYN-flood=
 attack.
> I do wonder if the DMAR events points to an issue in the kernel ?

Please send a compressed log including all 'fault addr' lines as well
as the (module probe time) XID line from the r8169 driver.

--=20
Ueimor
