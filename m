From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: xfrm_user: fix selector family initialization
Date: Mon, 14 Apr 2008 09:36:23 +0200
Message-ID: <48030977.3000909@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net> <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl> <47F4CF29.2000104@trash.net> <47F4E12B.3040508@trash.net> <BAY103-DAV125214C1E537F51083DAB6B2F70@phx.gbl> <47F4EB73.1040705@trash.net> <47FBC2AF.7050508@trash.net> <47FCE30F.8060400@trash.net> <BAY103-DAV9C5B38D48157167876C4FB2E80@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Kazunori MIYAZAWA <kazunori@miyazawa.org>,
	"David S. Miller" <davem@davemloft.net>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64491 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966AbYDNHg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 03:36:28 -0400
In-Reply-To: <BAY103-DAV9C5B38D48157167876C4FB2E80@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:
> Patrick McHardy wrote:
> 
>> Marco, could you test this patch please?
> 
> [sorry for the huge delay]
> 
> Openswan is happy with this patch. I have tested
> openswan 2.4.12 with linux 2.6.25-rc9
> Thanks for fixing this issue before 2.6.25 final.


Thanks Marco.
