From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Wed, 22 Feb 2012 18:41:34 +0100
Message-ID: <4F4528CE.7080702@linuxsystems.it>
References: <bug-42809-100@https.bugzilla.kernel.org/> <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:56888 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab2BVRv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 12:51:29 -0500
In-Reply-To: <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for CCing netdev, I was thinking about doing the same.

Il 22/02/2012 18:20, Stephen Hemminger ha scritto:
> That is a really old kernel now. Could you try with later kernel?

I can (a few minutes during night) but I really need a fix for 2.6.32.=20
This is a production server with dozens of Xen virtual machines and a=20
heavily patched kernel (xen dom0, layer 7, imq, esfq, advanced routing=20
etc). I did test a "vanilla" kernel last night (not really vanilla, but=
=20
a clean official debian kernel) and I had the same problem.

Thanks,
Niccol=F2
