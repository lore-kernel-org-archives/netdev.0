From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Wed, 07 Apr 2010 02:15:16 -0700 (PDT)
Message-ID: <20100407.021516.166296092.davem@davemloft.net>
References: <1270486884-10905-1-git-send-email-timo.teras@iki.fi>
	<20100406123404.GA24294@gondor.apana.org.au>
	<4BBB3684.8070807@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48479
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752353Ab0DGJPO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 05:15:14 -0400
In-Reply-To: <4BBB3684.8070807@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 06 Apr 2010 16:26:28 +0300

> As noticed in review of 2/4, this needs to be fixed by calling
> flow object delete() unconditionally if genid is outdated. I'll
> repost with this fixed for next iteration.

I went over the current versions of these patches and
the general scheme looks fine to me.

Please resubmit a new set of patches with the final fixes to the genid
delete handlign.

Thanks a lot for doing this work!
