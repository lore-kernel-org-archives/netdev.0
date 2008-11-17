From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: 2.6.28-rc5: Reported regressions from 2.6.27
Date: Mon, 17 Nov 2008 20:36:46 +0900
Message-ID: <1226921806.8582.6.camel@localhost.localdomain>
References: <VwdsQNEjR_C.A.CiD.9_FIJB@chimera>
	 <20081116182953.6231ae8c@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20081116182953.6231ae8c@lxorguk.ukuu.org.uk>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-11-16 at 18:29 +0000, Alan Cox wrote:
> >      the majority of these patches have not been merged for over two weeks
> >      (for almost three weeks in many cases and for over a _month_ in one case).
> >      IMO, this is insane.]
> 
> Some of them are quite serious too - some stuff is basically unusable in
> 2.6.28rc due to the vmalloc bug.
> 
> Is there any reason why someone (Rafael ?) shouldn't simply submit all of
> those patches that look sensible, are reported to fix regressions and
> whose maintainer has not provided a reason to NOT apply them into the
> tree ?

There is for SCSI.  Our two bugzilla entries each have several patches
(one has two, the other has four).  The patches listed in the
regressions aren't necessarily going to be the ones applied (depending
on how the arguing and testing goes).

James


