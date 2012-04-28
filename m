From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Sat, 28 Apr 2012 12:25:33 +0200
Message-ID: <4F9BC59D.80304@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120427134127.6d536a96@nehalam.linuxnetplumber.net> <20120427135514.48b03ce8@nehalam.linuxnetplumber.net> <4F9B2641.9070209@linuxsystems.it> <20120427194635.0b65b0ee@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:55798 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842Ab2D1KYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 06:24:43 -0400
In-Reply-To: <20120427194635.0b65b0ee@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 28/04/2012 04:46, Stephen Hemminger ha scritto:
> Are you using VLAN's? the whole problem report only applies if using =
VLAN
> on old hardware.

No, I don't use VLANs. There are VLANs in my network but I simply=20
connect to the default one from my laptop.

Niccol=F2
