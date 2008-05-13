From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 15:34:30 -0700 (PDT)
Message-ID: <20080513.153430.47909155.davem@davemloft.net>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>
	<OFDBD6E282.6F00998A-ON88257448.0056D40D-88257448.0057105E@us.ibm.com>
	<20080513162325.GF15306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754790AbYEMWef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 18:34:35 -0400
In-Reply-To: <20080513162325.GF15306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 13 May 2008 13:23:25 -0300

> What would be the problem of SOCK_DCCP being handled in glibc in such a
> fashion?

I don't understand why this isn't exactly what is being done.

We have to update glibc to handle SOCK_DCCP correctly, just
get over it :-)
