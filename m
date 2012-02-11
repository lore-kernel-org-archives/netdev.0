From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH v7 4/8] seccomp: Add SECCOMP_RET_TRAP
Date: Sun, 12 Feb 2012 00:33:09 +0400
Message-ID: <20120211203309.GA18093@albatros>
References: <1328935151-6908-1-git-send-email-wad@chromium.org>
 <1328935151-6908-5-git-send-email-wad@chromium.org>
 <CAObL_7FJ=a-X0UuVuK1p338nAVCes4H8PTe2ji5dOLhrtSaKHQ@mail.gmail.com>
 <CABqD9hYipmC1Dcx6+VrDM04ik5ysfw0GCypEzdFDBfh5B24jtA@mail.gmail.com>
 <20120211200346.GA16870@albatros>
 <1328991543.11026.8.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linun-security-module@vger.kernel.org, netdev@vger.kernel.org,
	kernel-hardening@lists.openwall.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328991543.11026.8.camel@joe2Laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 11, 2012 at 12:19 -0800, Joe Perches wrote:
> On Sun, 2012-02-12 at 00:03 +0400, Vasiliy Kulikov wrote:
> > On Sat, Feb 11, 2012 at 13:30 -0600, Will Drewry wrote:
> > > (As a side note, I realize the CC list has ballooned.  In the next
> > > rev, I'll pare it down to active participants and the appropriate
> > > lists and not just the get_maintainers.pl output!)
> > Add kernel-hardening to CC and remove me and Kees ;)
> 
> Should that list be added to MAINTAINERS or
> Documentation/ somewhere?

Probably yes, but we haven't fully agreed on what are the formal
criterias of k-h posting.  Currently these are either discussion of
not-yet-merged security features or general security problems of Linux.
I guess we should more clearly state the role of k-h to place k-h in
MAINTAINERS.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
