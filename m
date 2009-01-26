From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] Move config NET_NS to from net/Kconfig to
 init/Kconfig
Date: Mon, 26 Jan 2009 12:26:09 -0800 (PST)
Message-ID: <20090126.122609.217444769.davem@davemloft.net>
References: <1232755651.8282.6.camel@localhost>
	<20090126175845.GA19953@hallyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthltc@us.ibm.com, netdev@vger.kernel.org
To: serge@hallyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752056AbZAZU0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:26:07 -0500
In-Reply-To: <20090126175845.GA19953@hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Serge E. Hallyn" <serge@hallyn.com>
Date: Mon, 26 Jan 2009 11:58:45 -0600

> Quoting Matt Helsley (matthltc@us.ibm.com):
> > Make NET_NS available underneath the generic Namespaces config option since all of
> > the other namespace options are there.
> > 
> > Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
> 
> It would definately be nice to have all the namespace options in
> one place.
> 
> Acked-by: Serge Hallyn <serue@us.ibm.com>

Sounds good to me too, applied, thanks everyone.
