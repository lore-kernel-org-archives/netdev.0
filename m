From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipsec: Put dumpers on the dump list
Date: Wed, 01 Oct 2008 07:05:20 -0700 (PDT)
Message-ID: <20081001.070520.188665045.davem@davemloft.net>
References: <48E357C6.404@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751542AbYJAOFc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 10:05:32 -0400
In-Reply-To: <48E357C6.404@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 01 Oct 2008 13:58:14 +0300

> Herbert Xu came up with the idea and the original patch to make
> xfrm_state dump list contain also dumpers:
 ...
> Rebased to apply on top of "key: Free dumping state on socket
> close". No other changes compared to previous send.

Applied, thanks Timo!
