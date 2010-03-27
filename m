From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 13:03:58 +0100
Message-ID: <20100327120358.GA5114@electric-eye.fr.zoreil.com>
References: <4BADDDB7.4010005@iki.fi>
 <20100327114059.GA3432@electric-eye.fr.zoreil.com>
 <4BADF01E.9090906@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:58946 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752770Ab0C0ME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 08:04:26 -0400
Content-Disposition: inline
In-Reply-To: <4BADF01E.9090906@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s <timo.teras@iki.fi> :
[...]
> I don't think this would do anything. The high part is recorded corre=
ctly always.
> It's the 'low' part that gets discarded. I can do similar test if wri=
ting it
> more times will help. Will post results soon.

You may check whether writing MAC4 before MAC0 makes a difference
or not as well.

--=20
Ueimor
