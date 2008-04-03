From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Thu, 03 Apr 2008 14:35:53 +0200
Message-ID: <47F4CF29.2000104@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net> <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33054 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbYDCMf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 08:35:58 -0400
In-Reply-To: <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:
> Patrick McHardy wrote:
> 
>> haven't been much patches in this area since -rc4, does
>> reverting commit df9dcb458 help?
> 
> yess, I have reverted that commit:
> now openswan is happy again.
> As always, thanks a lot Patrick


Thanks, now we just have to figure out whats wrong with
that commit :)

I'll give it a try myself once the compile finishes.
