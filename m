From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: make unexported functions static
Date: Thu, 09 Jun 2016 08:47:41 -0400
Message-ID: <87fusm8r6a.fsf@ketchup.mtl.sfl>
References: <1465468206-2890-1-git-send-email-ben.dooks@codethink.co.uk> <87fusm8rbd.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Andrew Lunn <andrew@lunn.ch>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33642 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbcFIMro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 08:47:44 -0400
In-Reply-To: <87fusm8rbd.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> Most of them are fixed or being handled in net-next.
>
> I don't know if net should diverge or if it can live with these
> warnings...

In fact I have a series in net-next fixing a few checkpatch.pl issue. If
you don't mind I can rebase your fix and integrate the missing static.

Thanks,

        Vivien
