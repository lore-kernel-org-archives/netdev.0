From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Thu, 03 Apr 2008 13:19:27 +0200
Message-ID: <47F4BD3F.30703@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63719 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756128AbYDCLTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 07:19:34 -0400
In-Reply-To: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:
> Hi everybody,
> 
> openswan 2.4.12 doesn't work anymore
> with 2.6.25-rc8: quick mode is failing
> with this error:
> 
> ERROR: netlink response for Add SA esp.8a56fa21@1.1.1.1 included errno
> 93: Protocol not supported
> 
> I have tried both with des3 and aes but
> I get always the same error.

What does your policy look like?
