From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 21:54:45 +0200
Message-ID: <20060913195445.GH25007@electric-eye.fr.zoreil.com>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:20136 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751018AbWIMT47
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:56:59 -0400
To: Kumar Gala <galak@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala <galak@kernel.crashing.org> :
> What are good examples of simple/basic ethernet drivers one should  
> use to model a new driver off of?

tg3/bnx2/sky2/b44/8139cp

Shake, average, procrastinate.

It depends on what the hardware can do though.

-- 
Ueimor
