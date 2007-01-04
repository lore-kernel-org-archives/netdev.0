From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: revert to old definition of `before'
Date: Thu, 04 Jan 2007 12:25:36 -0800 (PST)
Message-ID: <20070104.122536.53337620.davem@davemloft.net>
References: <200701041254.55007@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030181AbXADUZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 15:25:36 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200701041254.55007@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 4 Jan 2007 12:54:54 +0000

> Hi Dave,
> 
> as per earlier email, can you please revert the definition of the
> TCP `before' relation: there is code which implicitly depends on it.
> 
> Furthermore, this definition appears in textbooks such as Stevens
> and therefore, even if the newer definition may have nicer properties,
> it is safer to stick with the old one.

No problem, patch applied, thanks Gerrit.
