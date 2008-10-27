From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Mon, 27 Oct 2008 12:28:47 -0700 (PDT)
Message-ID: <20081027.122847.01988386.davem@davemloft.net>
References: <48F967BA.4090102@cosmosbay.com>
	<20081020000756.GB21172@localhost.localdomain>
	<48FC3D83.8060905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru, shemminger@vyatta.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbYJ0T3K convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 15:29:10 -0400
In-Reply-To: <48FC3D83.8060905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 20 Oct 2008 10:12:51 +0200

> Neil Horman a =E9crit :
> > Ok, one more revision. It takes Erics final suggestions into accoun=
t.  Eric, as
> > per your request, I've added your signed off line to it.
> > This is a patch to provide on demand route cache rebuilding.
 ...
> Thanks Neil for your patience, this patch is fine.

Applied, thanks everyone.
