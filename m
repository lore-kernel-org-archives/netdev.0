From: David Miller <davem@davemloft.net>
Subject: Re: [Regression, in, 2.6.29] forcedeth doesn't work after resume
 from hibernation
Date: Mon, 06 Apr 2009 17:49:39 -0700 (PDT)
Message-ID: <20090406.174939.219219089.davem@davemloft.net>
References: <20090404.165421.142076064.davem@davemloft.net>
	<1239026612.23068.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eswierk@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60090
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbZDGAtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 20:49:50 -0400
In-Reply-To: <1239026612.23068.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Swierk <eswierk@aristanetworks.com>
Date: Mon, 06 Apr 2009 07:03:32 -0700

> Reset phy state on resume, fixing a regression caused by powering down
> the phy on hibernate.
> 
> Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>

Applied, thanks.
