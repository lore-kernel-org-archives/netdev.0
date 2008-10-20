From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Mon, 20 Oct 2008 09:51:18 +0000
Message-ID: <20081020095118.GB6203@ff.dom.local>
References: <bug-11721-11547@http.bugzilla.kernel.org/> <20081018202056.F1933108040@picon.linux-foundation.org> <20081018210252.GA6048@ami.dom.local> <20081018215007.GB6048@ami.dom.local> <Pine.LNX.4.64.0810201106200.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:57432 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbYJTJvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:51:25 -0400
Received: by ey-out-2122.google.com with SMTP id 6so532678eyi.37
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 02:51:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810201106200.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2008 at 12:38:51PM +0300, Ilpo J=E4rvinen wrote:
=2E..
> ...Might be something crazy in the way that is too picky on tcp optio=
n=20
> ordering which wouldn't surprise me that much... :-) Please try if
> the patch below does any difference (on paperino is enough, the gw se=
ems=20
> innocent here).

I've just thought about this too(!), and it seems that turning of
tcp_timestamps should do similar reorder. But of course, I'll try
not to disturb anymore...

Thanks,
Jarek P.
