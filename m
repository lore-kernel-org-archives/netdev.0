From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Thu, 3 Apr 2008 14:31:36 +0200
Message-ID: <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net>
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s23.bay0.hotmail.com ([65.54.246.159]:20578 "EHLO
	bay0-omc2-s23.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752385AbYDCMdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 08:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

> haven't been much patches in this area since -rc4, does
> reverting commit df9dcb458 help?

yess, I have reverted that commit:
now openswan is happy again.
As always, thanks a lot Patrick


