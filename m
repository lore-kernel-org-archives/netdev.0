From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.22-rc3: known regressions
Date: Tue, 29 May 2007 14:56:20 +0200
Message-ID: <465C22F4.8080505__38828.6073263318$1180443408$gmane$org@googlemail.com>
References: <465C188F.9000900@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Ruben <nahoo82@terra.es>,
	Stephen Hemminger <shemminger@osdl.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, Greg KH <greg@kroah.com>,
	"Mike Miller (OS Dev)" <mikem@beardog.cca.cpqcorp.net>,
	tom.l.nguyen@intel.com, linux-pcmcia@lists.infradead.org,
	Robert de Rooy <robert.de.rooy@gmail.com>,
	Alan Cox <alan@redhat.com>, Tejun Heo <htejun@gmail.com>,
	linux-ide@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Gregor Jasny <gjasny@googlemail.com>,
	sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mikael Pettersson <mikpe@it.uu.se>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:40976 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbXE2M4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 08:56:33 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1852065ugf
        for <netdev@vger.kernel.org>; Tue, 29 May 2007 05:56:31 -0700 (PDT)
In-Reply-To: <465C188F.9000900@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc3.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Networking

Subject    : Network card not usable - sky2
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8539
Submitter  : Ruben <nahoo82@terra.es>
Status     : Unknown



PCI

Subject    : Oops on 2.6.22-rc2 when unloading the cciss driver
References : http://lkml.org/lkml/2007/5/24/172
Submitter  : Mike Miller (OS Dev) <mikem@beardog.cca.cpqcorp.net>
Status     : Unknown



PCMCIA

Subject    : libata and legacy ide pcmcia failure
References : http://lkml.org/lkml/2007/5/17/305
Submitter  : Robert de Rooy <robert.de.rooy@gmail.com>
Status     : Unknown



SATA/PATA

Subject    : 22-rc3 broke the CDROM in Dell notebook
References : http://lkml.org/lkml/2007/5/27/63
Submitter  : Gregor Jasny <gjasny@googlemail.com>
Handled-By : Tejun Heo <htejun@gmail.com>
             Jeff Garzik <jeff@garzik.org>
Caused-By  : Tejun Heo <htejun@gmail.com>
             commit d4b2bab4f26345ea1803feb23ea92fbe3f6b77bc
Status     : problem is being debugged



Sparc64

Subject    : 2.6.22-rc broke X on Ultra5
References : http://lkml.org/lkml/2007/5/22/78
Submitter  : Mikael Pettersson <mikpe@it.uu.se>
Status     : Unknown



Regards,
Michal

--
"Najbardziej brakowa=B3o mi twojego milczenia."
-- Andrzej Sapkowski "Co=B6 wi=EAcej"

