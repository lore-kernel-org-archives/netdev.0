From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Wed, 27 May 2009 00:40:41 +0200
Message-ID: <4A1C6FE9.1050003@googlemail.com>
References: <20090525.225503.173348268.davem@davemloft.net>	<200905262022.24593.mb@bu3sch.de>	<20090526.145211.37114439.davem@davemloft.net> <20090526.151410.109935435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, dave@thedillows.org, romieu@fr.zoreil.com,
	rsantos@grupopie.com, m.bueker@berlin.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:47829 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756459AbZEZWkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 18:40:43 -0400
In-Reply-To: <20090526.151410.109935435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 26 May 2009 14:52:11 -0700 (PDT)
> 
> 
>>From: Michael Buesch <mb@bu3sch.de>
>>Date: Tue, 26 May 2009 20:22:23 +0200
>>
>>
>>>I didn't notice a CC:stable.
>>>I think this should also go to stable.
>>>Does somebody take care?
>>
>>I'll queue it up.
> 
> 
> Actually, this patch doesn't even remotely come close to applying
> to 2.6.29.4

Michael Buesch already provided a patch against 2.6.29.4 that we both
tested. I doubt that it will apply to 2.6.27 cleanly, though.

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
