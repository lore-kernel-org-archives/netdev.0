From: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe in
	back trace (regression)
Date: Tue, 28 Jul 2009 14:40:21 +0800
Message-ID: <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org>
	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
	<20090723000100.d74d6b1c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:51618 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbZG1Gkl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 02:40:41 -0400
Received: by gxk9 with SMTP id 9so6851836gxk.13
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 23:40:41 -0700 (PDT)
In-Reply-To: <20090723000100.d74d6b1c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]
> Could have been a problem in net core, perhaps.
>
> Below is a ppp fix from 2.6.31, but it seems unlikely to fix your pro=
blem.
>
> It would help if we could see that trace, please. =C2=A0A digital pho=
to
> would suit.

	Here it is:

		http://bugzilla.kernel.org/attachment.cgi?id=3D22516

	(It's 2.6.30.3)
=09
--=20
End of message. Next message?
