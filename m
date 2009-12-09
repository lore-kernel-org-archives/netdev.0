From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] atm: [he] adjust tests to account for
 sk_wmem_alloc changes
Date: Tue, 08 Dec 2009 20:22:49 -0800 (PST)
Message-ID: <20091208.202249.202139382.davem@davemloft.net>
References: <200912041522.nB4FMHgq028277@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756732AbZLIEWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:22:42 -0500
In-Reply-To: <200912041522.nB4FMHgq028277@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Fri, 04 Dec 2009 10:22:17 -0500

> From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> 
> atm: [he] adjust tests to account for sk_wmem_alloc changes
> 
> due to reference counting sk_wmem_alloc now has a value of 1 when all
> the outstanding data has been sent.
> 
> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
