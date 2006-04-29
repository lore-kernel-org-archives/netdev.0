From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: IP1000 gigabit nic driver
Date: Sat, 29 Apr 2006 13:29:26 +0300
Message-ID: <1146306567.1642.3.camel@localhost>
References: <20060427142939.GA31473@fargo>
	 <20060427185627.GA30871@electric-eye.fr.zoreil.com>
	 <445144FF.4070703@cantab.net> <20060428075725.GA18957@fargo>
	 <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com>
	 <20060428113755.GA7419@fargo>
	 <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Vrabel <dvrabel@cantab.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:25286 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP
	id S1750704AbWD2K3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 06:29:30 -0400
To: "David =?ISO-8859-1?Q?G=F3mez?=" <david@pleyades.net>
In-Reply-To: <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006, David G=F3mezz wrote:
> > Ok, i could take care of that, and it's a good way of getting my ha=
nds
> > dirty with kernel programming ;). David, if it's ok to you i'll do =
the
> > cleanup thing.

On Fri, 2006-04-28 at 14:59 +0300, Pekka J Enberg wrote:
> Here are some suggestions for coding style cleanups:

[snip]

I ended up doing most of them myself [1]. Sorry :-) Are the datasheets
public by the way?

			Pekka

  1. http://www.cs.helsinki.fi/u/penberg/linux/ip1000-driver.patch

