From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH] sky2: override for PCI legacy power management
Date: Sun, 6 May 2012 17:26:30 -0500
Message-ID: <20120506222630.GA32309@burratino>
References: <4F69BE2E.7070903@t-online.de>
 <20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
 <CAErSpo67PEaZ6JuMUntWLfR8SUpQgZERD_cKV6rWd=FF0tZ6DQ@mail.gmail.com>
 <4F6BA960.6020003@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>, arekm@maven.pl,
	Jared <nitro@legroom.net>, dilieto@lineone.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Knut Petersen <Knut_Petersen@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:56221 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778Ab2EFW0k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 18:26:40 -0400
Content-Disposition: inline
In-Reply-To: <4F6BA960.6020003@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Knut Petersen wrote, a few months ago:

> It=C2=B4s easy to dmi_match() known broken systems - I have dmidecode
> outputs of four systems that definitely need the patch.
>
> Two ASUSTek P5* mainboards with AMI BIOSes, two AOpen i915G*
> mainboards with Award/Phoenix BIOSes.

Yes, please.  Could you attach those to [1]?

Thanks,
Jonathan

[1] https://bugzilla.kernel.org/show_bug.cgi?id=3D19492
