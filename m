From: "Damon L. Chesser" <damon@damtek.com>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Thu, 08 May 2008 13:05:38 -0400
Message-ID: <482332E2.6080104@damtek.com>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi> <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bug 213081 <213081@bugs.launchpad.net>, 478062@bugs.debian.org,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from damtek.com ([72.172.134.65]:34571 "EHLO damtek.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbYEHRFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 13:05:16 -0400
In-Reply-To: <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:

Snip
>
> Could you next try with tcp_frto set to 1, if my theory proves to be=20
> correct, it too should be "enough" to fix the problem (in this=20
> particular case). Of course you can verify the patch below too if you=
=20
> want to, the patch should allow cups<->printer to work with tcp_frto =
=3D=20
> 2 too. In case you have problem to apply the patch to the particular=20
> version you're want to try with, just send a note about the version=20
> number to me so I can adapt the patch for you (space etc. formatting=20
> issues may show up because I recently run a code style cleanup on the=
=20
> tcp code).
>
Ilpo,

and all others, please ignore frtoprob1.txt.  I ran the test on the=20
wrong kernel.  The tested kernel was 2.6.23.17-amd64 and should have=20
been 2.6.24-1-amd64.  I am re-running the test and will forward the new=
=20
dump.  No idea why 2.6.23.17 did not print, it always did before.  I am=
=20
sure I did something stupid, feeling a bit under the weather.  Sorry fo=
r=20
the confusion.  New test comming shortly.



--=20
Damon L. Chesser
damon@damtek.com
http://www.linkedin.com/in/dchesser


