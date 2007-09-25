From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 25 Sep 2007 21:09:46 +0200
Message-ID: <46F95CFA.8060908@hartkopp.net>
References: <20070925122029.15989.0@janus.isnogud.escape.de>	<20070925122244.15989.5@janus.isnogud.escape.de>	<20070925.222631.116063075.yoshfuji@linux-ipv6.org> <ygfir5yetfp.fsf@janus.isnogud.escape.de> <46F91F64.2050008@trash.net> <46F94B91.5020209@hartkopp.net> <46F94B00.3060006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	davem@davemloft.net, joe@perches.com, tglx@linutronix.de,
	oliver.hartkopp@volkswagen.de
To: Patrick McHardy <kaber@trash.net>,
	=?ISO-8859-15?Q?YOSHIFUJI_Hideak?=
	 =?ISO-8859-15?Q?i_/_=C8=A3=D1=C0?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:16183 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbXIYTKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 15:10:43 -0400
In-Reply-To: <46F94B00.3060006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>
> Yoshifuji's point was that the license seems to contradict itself,
> it says you may choose GPL, but have to retain BSD. And that is
> not about Dual BSD/GPL but about the specific wording.
>   

Got it (finally)!

Trying to specify the GPL Version (and the reference to the COPYING
file) i just overlooked  the second part
 "*/*/in which case the provisions of the GPL apply INSTEAD OF those
given above."/*/* of the original sentence.

Sorry. Was no* malice aforethought :)*

Of course we'll fix this to have the same wording like e.g. in
arch/i386/crypto/aes.c .

Thanks to Yoshfuji for catching this and to Patrick for making it clear
to me!*

Best regards,
Oliver

*

