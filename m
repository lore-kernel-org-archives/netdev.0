From: David Miller <davem@davemloft.net>
Subject: Re: SCTP control socket question
Date: Thu, 27 Mar 2008 20:30:22 -0700 (PDT)
Message-ID: <20080327.203022.206165507.davem@davemloft.net>
References: <1206625405.2109.7.camel@iris.sw.ru>
	<47EBA8A7.4080503@hp.com>
	<47EBAC19.2050301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, den@openvz.org, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39742
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752331AbYC1DaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 23:30:22 -0400
In-Reply-To: <47EBAC19.2050301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 27 Mar 2008 17:15:53 +0300

> >> will you mind against this?
> >>
> > 
> > That's fine.  My one concern is that someone may erroneously interpret that SCTP
> > sockets are derived from inet_connection_sock, but I can live with that.
> 
> Agree. I'd rename it into some not-so-inet-related function.

Can someone formally submit a final patch?

Thanks.
