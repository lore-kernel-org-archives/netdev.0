From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: RE: Git broken for IPW2200
Date: Thu, 8 Sep 2005 09:45:30 -0600
Message-ID: <003901c5b48c$580e7210$a20cc60a@amer.sykes.com>
References: <432057D6.3010208@spamtest.viacore.net>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ieee80211-devel@lists.sourceforge.net>,
	"'linux-kernel'" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932596AbVIHPpj@vger.kernel.org>
To: "'Joe Bob Spamtest'" <joebob@spamtest.viacore.net>
In-Reply-To: <432057D6.3010208@spamtest.viacore.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




> IPW2200 requires a different ieee80211 stack, this can be had at
> ieee80211.sourceforge.net

Joe,

	The stack is already in mainline in Linus Git. I should not need to
download the ieee80211 from any place but compile with the one in the
kernel.

.Alejandro

>
>
> Alejandro Bonilla Beeche wrote:
> > Hi,
> >
> > 	Where does one report this? I was building Linus Git
> tree as per I
> > updated it at 09/07/2005 7:00PM PDT and got this while compiling.
> >
> > Where do I report this?
> >
> > Debian unstable updated at same time.
> >
> > it looks like ipw2200 is thinking that ieee80211 is not
> compiled in, but
> > I did select it as a module?
> >
> > drivers/net/wireless/ipw2200.c:6676: error: dereferencing pointer to
