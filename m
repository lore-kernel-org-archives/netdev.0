From: Peter Foley <pefoley2@pefoley.com>
Subject: Re: [PATCH] Documentation: ptp: Fix build failure on MIPS cross builds
Date: Wed, 22 Oct 2014 10:09:37 -0400
Message-ID: <CAOFdcFO=aLHKtogCf3Sz+XFFcm56JSTi=Om7S+XLdr71YCnFaw@mail.gmail.com>
References: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com>
 <20141021110724.GA16479@netboy> <20141021.123544.9516812519754063.davem@davemloft.net>
 <544690CB.4030307@gmail.com> <20141021182757.GA3960@localhost.localdomain>
 <CAOFdcFNYHgupvMChb4NedMsUMAOmE8k0D_F5eRjL-8H8ft=eRw@mail.gmail.com> <20141022080302.GA4037@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Daney <ddaney.cavm@gmail.com>,
	David Miller <davem@davemloft.net>, markos.chandras@imgtec.com,
	linux-mips@linux-mips.org, corbet@lwn.net, netdev@vger.kernel.org,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141022080302.GA4037@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 22, 2014 at 4:03 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> In the mean time, I would like to restore the testptp.mk that *does*
> cross compile, so that people may use the test program if they
> want. In fact I use this all the time, and so I am a bit annoyed that
> something working was deleted and replaced with something broken.

Sure, I didn't realize that anyone was actually using testptp.mk on a
regular basis.
Feel free to restore it.
