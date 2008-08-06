From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/4] list.h: add list_cut_position()
Date: Wed, 6 Aug 2008 13:32:51 -0700
Message-ID: <20080806203251.GB9519@tesla>
References: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com> <20080804160011.ec964f1f.randy.dunlap@oracle.com> <20080804231320.GG6447@tesla> <ef1cd66f0808050152g1dd8b96cl2df820607d480f0f@mail.gmail.com> <20080806182724.GI5605@tesla> <23052053.1218047754579.JavaMail.oracle@acsmt304.oracle.com> <20080806184520.GK5605@tesla> <20080806202854.GP5605@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Jochen =?iso-8859-1?B?Vm/f?= <jochen.voss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org" <ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
To: Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080806202854.GP5605@tesla>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2008 at 01:28:54PM -0700, Luis Rodriguez wrote:
> On Wed, Aug 06, 2008 at 11:45:20AM -0700, Luis Rodriguez wrote:
> >
> > OK here's the new one.
> > --
> >
> > This adds list_cut_position() which lets you cut a list into
> > two lists given a pivot in the list.
> >
> > Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> 
> Here it is again but this time one which applies cleanly ontop of the
> list_cut_tail() patch I just reposted.

I meant on top of the list_splice_tail() of course :)

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
