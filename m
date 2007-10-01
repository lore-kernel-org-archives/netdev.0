From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24 0/4]: TCP fixes
Date: Mon, 01 Oct 2007 15:29:19 -0700 (PDT)
Message-ID: <20071001.152919.118977894.davem@davemloft.net>
References: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54562
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751930AbXJAW3T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 18:29:19 -0400
In-Reply-To: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon,  1 Oct 2007 15:29:40 +0300

> This fixes the newreno fackets_out case, which turned out to be
> not related to the Cedric's case being under investigation. Two
> trivial comment patches, and frto with high-speed seqno
> wrap-around protection. Compile tested. Please apply to
> net-2.6.24.

I've applied them all to net-2.6.24, thanks Ilpo!
