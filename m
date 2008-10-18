From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Sat, 18 Oct 2008 23:50:07 +0200
Message-ID: <20081018215007.GB6048@ami.dom.local>
References: <bug-11721-11547@http.bugzilla.kernel.org/> <20081018202056.F1933108040@picon.linux-foundation.org> <20081018210252.GA6048@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:13942 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbYJRVuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 17:50:13 -0400
Received: by ug-out-1314.google.com with SMTP id k3so376975ugf.37
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2008 14:50:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081018210252.GA6048@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[RESEND] I forgot to add Aldo's email before - sorry!

On Sat, Oct 18, 2008 at 11:02:52PM +0200, Jarek Poplawski wrote:
> Nice job Aldo!
> 
> I forward this message to netdev and Cc our best tcp expert.
> Any new replies should be rather "Reply All" (not bugzilla only).
> 
> Thanks,
> Jarek P.
> 
> On Sat, Oct 18, 2008 at 01:20:56PM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=11721
> > 
> ...
> > ------- Comment #30 from sentiniate@tiscali.it  2008-10-18 13:20 -------
> > absolutely i'm not fed up! and actually i thank you for your patience.
> > 
> > i set paperino as you wrote and added ifconfig eth0 mtu 1400 as well
> > i set the same value of mtu in topolino as well, i hope i was not wrong doing
> > so!
> > 
> > i attach the files you ask for, but now i can navigate with 2.6.27-rc1-git1 as
> > well!
> > 
> > afterwards i've run some more tests and have found out that the culprit is
> > tcp_sack, if using kernel 2.6.27-rc1-gt1 it is set to "1" i cannot navigate if
> > to "0" i can.
> > so i enclose, should it be of any help, also the tcpdump on eth0 of topolino
> > when on paperino tcp_sack is set to "1".
> > 
> > thanks
> > aldo
> > 
> > 
> > -- 
> > Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> > ------- You are receiving this mail because: -------
> > You are on the CC list for the bug, or are watching someone who is.
