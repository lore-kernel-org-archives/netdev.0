From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug #14261] e1000e jumbo frames no longer work: 'Unsupported MTU setting'
Date: Fri, 2 Oct 2009 23:31:35 +0200
Message-ID: <200910022331.35916.rjw@sisk.pl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.jd.5MTxKB@chimera> <877hvd8rj5.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Alexander Duyck" <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jesse Brandeburg <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Nix <nix-dKoSMcxRz+Te9xe1eoZjHA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877hvd8rj5.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 02 October 2009, Nix wrote:
> On 1 Oct 2009, Rafael J. Wysocki stated:
> 
> > The following bug entry is on the current list of known regressions
> > introduced between 2.6.30 and 2.6.31.  Please verify if it still should
> > be listed and let me know (either way).
> 
> The patch fixes it.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14261
> > Subject		: e1000e jumbo frames no longer work: 'Unsupported MTU setting'
> > Submitter	: Nix <nix-dKoSMcxRz+Te9xe1eoZjHA@public.gmane.org>
> > Date		: 2009-09-26 11:16 (6 days old)
> > References	: http://marc.info/?l=linux-kernel&m=125396433321342&w=4
> > Handled-By	: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Patch		: http://patchwork.kernel.org/patch/50277/
> 
> (Possibly a stable candidate? It's not in 2.6.31.2-to-be, perhaps the
> only patch that isn't. ;) )

Most likely because it's not in the Linus' tree yet.

[e1000e maintainers, we have a regression fix to merge, please.]

Thanks,
Rafael
