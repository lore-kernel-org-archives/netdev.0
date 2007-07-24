From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 09:12:01 +0200
Message-ID: <20070724071201.GA7134@electric-eye.fr.zoreil.com>
References: <20070723.210748.63127793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	rusty@rustcorp.com.au, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38929 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765579AbXGXHOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 03:14:25 -0400
Content-Disposition: inline
In-Reply-To: <20070723.210748.63127793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
[...]
> I also didn't play with turning off NAPI in kconfig where drivers
> allow that, can we just get rid of that crap already? :-/

Would it be accepted for 2.6.23 or must it be considered post-2.6.23 ?

-- 
Ueimor
