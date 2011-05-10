From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic
 constants.
Date: Tue, 10 May 2011 15:30:51 -0700 (PDT)
Message-ID: <20110510.153051.71135029.davem@davemloft.net>
References: <20110509.223118.260083861.davem@davemloft.net>
	<alpine.LFD.2.00.1105110123001.4532@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041Ab1EJWbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 18:31:23 -0400
In-Reply-To: <alpine.LFD.2.00.1105110123001.4532@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 11 May 2011 01:26:09 +0300 (EEST)

> 
> 	Fix more IP_VS_RT_MODE_* constants
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Following patch can be used after patch 4, eg. as
> number 6 because patches 4 and 5 are ok and we are going to replace
> patches 6 and 7.

Thanks Julian.

What I'm going to do is hold back the IPVS parts of the patches I
posted last night.  In particular, I'll integrate this into the
original patch #4.

And then we can work through the reimplementation ideas you posted to
me in private email.

If you could post those ideas here on the list I'd appreciate it,
so others can follow along and provide feedback.

Thanks!
