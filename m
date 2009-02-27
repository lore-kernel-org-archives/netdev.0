From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/26] Reliable Datagram Sockets (RDS), take 2
Date: Fri, 27 Feb 2009 00:01:50 -0800 (PST)
Message-ID: <20090227.000150.177646700.davem@davemloft.net>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<20090224.232814.227017310.davem@davemloft.net>
	<c0a09e5c0902251043x576e7066kb7aa76fc148a6f76@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753142AbZB0ICG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 03:02:06 -0500
In-Reply-To: <c0a09e5c0902251043x576e7066kb7aa76fc148a6f76@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Grover <andy.grover@gmail.com>
Date: Wed, 25 Feb 2009 10:43:27 -0800

> On Tue, Feb 24, 2009 at 11:28 PM, David Miller <davem@davemloft.net> wrote:
> > Furthermore the port you've choosen for the protocol is arbitrary, not
> > properly allocated with the appropriate standards committee, and
> > therefore could conflict with something other people are using.
> 
> I'm sure allocating the port won't be too big an issue.

Ok, I added the RDS code to the net-next-2.6 tree, changing
AF_RDS to be 21
