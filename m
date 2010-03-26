From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Fri, 26 Mar 2010 21:29:37 +0100
Message-ID: <20100326202937.GA3406@electric-eye.fr.zoreil.com>
References: <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
 <20100325113038.GA3471@swordfish.minsk.epam.com>
 <1269523180.3626.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:42677 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751512Ab0CZVBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 17:01:24 -0400
Content-Disposition: inline
In-Reply-To: <1269523180.3626.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> Thanks for the report. Problem is I am not confident enough on this
> driver.

Your patch is simple and it improves things.

> I believe Fran=E7ois Romieu is the one that can possibly push a patch=
 ?

=46eel free to push.

--=20
Ueimor
