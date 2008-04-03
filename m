From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Thu, 3 Apr 2008 16:06:20 +0200
Message-ID: <BAY103-DAV125214C1E537F51083DAB6B2F70@phx.gbl>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net> <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl> <47F4CF29.2000104@trash.net> <47F4E12B.3040508@trash.net>
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s21.bay0.hotmail.com ([65.54.246.157]:63226 "EHLO
	bay0-omc2-s21.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757444AbYDCOIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 10:08:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

> Manually adding SAs works fine for me, can you figure out what
> kind of SA openswan was trying to add?

I have sent you the output of ip -s x s
and ip -s x p when openswan is working with
2.6.25-rc8 with the commit df9dcb458 reverted.
Let me know you need ssh access to my 2.6.25
box.


