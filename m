From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: 3.7.10 kernel crash
Date: Wed, 03 Apr 2013 07:49:01 -0400
Message-ID: <1364989741.3825.27.camel@thor.lan>
References: <CADpTngWo_c0MHNwYEFwSR_9KQrWKrOVgQSze+rZc4Ze9Rj2hsw@mail.gmail.com>
	 <CADpTngW8RTVX28bVJQe5tV_ccc+FNOJezeQbczXFudy+7bMRDQ@mail.gmail.com>
	 <1364474147.3261.1.camel@thor.lan> <1426784.IFBeqasnTm@calvin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Fabio Coatti <fabio.coatti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426784.IFBeqasnTm@calvin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-02 at 11:16 +0200, Fabio Coatti wrote:
> Ok, I'll try to get better oopes. However, this is going to be tricky, as the 
> machine is remotely administered (via HP iLO) and uses all network interfaces 
> (BTW, I'm not even sure to be able to get a network driver related crash using 
> netconsole approach)

I use a separate network adapter specifically dedicated for netconsole
(but then I'm trying to crash the machine :)

> So far, no success in using a different resolution for 
> boot console.

What distribution is this and what bootloader are you using?
