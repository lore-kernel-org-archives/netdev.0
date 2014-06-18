From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Wed, 18 Jun 2014 12:25:19 +0200
Message-ID: <1403087119.1984.93.camel@x220>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Oleksij Rempel <linux@rempel-privat.de>,
	Richard Weinberger <richard@nod.at>,
	Jonathan Bither <jonbither@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	ath5k-devel@venema.h4ckr.net, open@hauke-m.de, list@hauke-m.de,
	antonynpavlov@gmail.com, openwrt-devel@lists.openwrt.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri, Nick, Luis, John,

On Wed, 2014-04-16 at 13:20 +0400, Sergey Ryazanov wrote:
> 2014-04-15 21:08 GMT+04:00 Paul Bolle <pebolle@tiscali.nl>:
> > On Thu, 2014-02-13 at 15:14 -0500, John W. Linville wrote:
> >> On Wed, Feb 12, 2014 at 02:50:30PM +0400, Sergey Ryazanov wrote:
> >> > John, can you delay the merging of this patch for a few months, I will
> >> > try to prepare the necessary patches to add AR231x architecture to the
> >> > kernel and send them to linux-mips.
> >>
> >> OK -- looking forward to your patches.
> >
> > So am I. Is there any news on this front?
> >
> 
> Work still in progress :(

ATHEROS_AR231X and the things depending on it, like AHB bus support,
have been discussed for three years now. When will you (re)consider a
patch to remove all currently dead code?

And to state the obvious: AHB bus support, and the other code depending
on ATHEROS_AR231X, can always be re-added once ATHEROS_AR231X gets added
to the tree.


Paul Bolle
