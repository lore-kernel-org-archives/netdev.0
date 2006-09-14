From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/12] smc911x: Fix SMC_WRITE_EEPROM_CMD macro
Date: Thu, 14 Sep 2006 19:59:17 +0200
Message-ID: <20060914175917.GA15904@electric-eye.fr.zoreil.com>
References: <200609132053.57258.bora.sahin@ttnet.net.tr> <20060913190143.GA25007@electric-eye.fr.zoreil.com> <200609141146.14129.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:8923 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750833AbWINSBA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 14:01:00 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609141146.14129.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
> Do you think if I convert them(smc911x.h) to static inline, would
> that be correct ?

Yes.

You can probably forget 'inline'.

-- 
Ueimor
