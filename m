From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Fri, 05 Sep 2014 13:33:44 +0200
Message-ID: <1409916824.7832.20.camel@x220>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
	 <1391971686-9517-10-git-send-email-richard@nod.at>
	 <52F7D480.1050106@hauke-m.de> <52F7DF21.70207@nod.at>
	 <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
	 <52F8C373.9060108@rempel-privat.de>
	 <CAHNKnsQF5Hdf3JT91moPraRQzn4kMpdD2NSiJ7b30wQhS1W4MA@mail.gmail.com>
	 <CAGVrzcYnECx5Q=i+m6qZn29y4JALDpw5SWoUNP-S6HgPR3_ygQ@mail.gmail.com>
	 <CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
	 <CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ@mail.gmail.com>
	 <20140213201421.GJ22203@tuxdriver.com> <1397581703.8212.5.camel@x220>
	 <CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>
	 <1403087119.1984.93.camel@x220>
	 <CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>
	 <1403091974.1984.102.camel@x220> <1409911856.7832.9.camel@x220>
	 <CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>,
	Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>,
	Jonathan Bither <jonbither-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	ath5k-devel-juf53994utBLZpfksSYvnA@public.gmane.org, open-5/S+JYg5SzeELgA04lAiVw@public.gmane.org, list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org,
	antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, openwrt-devel-ZwoEplunGu0+xA9t4nZiwti2O/JbrIOy@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sergey,

On Fri, 2014-09-05 at 15:12 +0400, Sergey Ryazanov wrote:
> 2014-09-05 14:10 GMT+04:00, Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>:
> > On Wed, 2014-06-18 at 13:46 +0200, Paul Bolle wrote:
> >> Having this conversation every rc1 is getting a bit silly. Could Jiri
> >> e.a. perhaps set some specific deadline for ATHEROS_AR231X to be
> >> submitted?
> >
> > I waited until rc3. Have you seen any activity on this front? If not,
> > should I resend the patch that removes the code in mainline that depends
> > on ATHEROS_AR231X (ie, AHB bus support)?
> >
> Recent activity always could be found in [1]. Now I finish another one
> round of cleanups and have a plan to fix several things (you can
> always find something that you really want to improve). But if you
> insist I could immediately switch to "send upstream" mode. And seems
> that this would be better approach.
> 
> 1. https://dev.openwrt.org/log/trunk/target/linux/atheros

And where can the related PULL requests or patch submissions be found?


Paul Bolle

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
