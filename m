From: David Miller <davem@davemloft.net>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 18:44:54 -0700 (PDT)
Message-ID: <20080707.184454.168388833.davem@davemloft.net>
References: <48729DAD.8010400@hp.com>
	<20080707.160029.13296246.davem@davemloft.net>
	<4872A652.2050709@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aglo@citi.umich.edu, shemminger@vyatta.com, netdev@vger.kernel.org,
	rees@umich.edu, bfields@fieldses.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40309
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755067AbYGHBoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 21:44:55 -0400
In-Reply-To: <4872A652.2050709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 07 Jul 2008 16:27:14 -0700

> David Miller wrote:
> > Setting TCP socket buffer via setsockopt() is always wrong.
> 
> Does that apply equally to SO_SNDBUF and SO_RCVBUF?

Yes.
