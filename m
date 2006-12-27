From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: d80211 constants inside d80211_common.h
Date: Wed, 27 Dec 2006 20:01:17 +0200
Message-ID: <40f31dec0612271001n2542d3a2w6c58536fd6b10b18@mail.gmail.com>
References: <40f31dec0612270032g284160a8q2c6f190b4296a455@mail.gmail.com>
	 <200612271107.45572.flamingice@sourmilk.net>
	 <40f31dec0612270926m6447309do7cbf78b28ee904ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"David Kimdon" <david.kimdon@devicescape.com>,
	linville@tuxdriver.com, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:5860 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705AbWL0SBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 13:01:18 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4295662wxd
        for <netdev@vger.kernel.org>; Wed, 27 Dec 2006 10:01:17 -0800 (PST)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <40f31dec0612270926m6447309do7cbf78b28ee904ae@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anyway it's not a problem to get phytypes outside dadwifi, but i think
it's low level stuff that's generaly needed. The main cause for my
mail was to capitalize them, anywhere they get inside kernel source.


Thanx for your time
Nick

2006/12/27, Nick Kossifidis <mickflemm@gmail.com>:
> We need those definitions for setting up the rate tables in dadwifi,
> phytypes are needed inside drivers, take a look here ->
> http://madwifi.org/browser/branches/dadwifi-openhal/openhal/ar5xxx.h?rev=1867
>
> Even if it does get out, constants should be in capitals.
>
>
> Thanx for your time
> Nick
>
> 2006/12/27, Michael Wu <flamingice@sourmilk.net>:
> > On Wednesday 27 December 2006 03:32, Nick Kossifidis wrote:
> > > I did a grep inside drivers/net/wireless/d80211/* and they are not
> > > used yet in drivers. Can you plz fix it before drivers start using
> > > them ?
> > Already fixed, just waiting for wireless-dev to get it.
> >
> > http://kernel.org/git/?p=linux/kernel/git/jbenc/dscape.git;a=commitdiff;h=4ae94181f808da96352478c6d4102e3b0b5dfaac
> >
> > -Michael Wu
> >
> >
> >
>
