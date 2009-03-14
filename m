From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/10] Neterion: New driver: Kconfig and Makefile
Date: Sat, 14 Mar 2009 11:44:36 -0700 (PDT)
Message-ID: <20090314.114436.141673098.davem@davemloft.net>
References: <1237018842.4966.418.camel@flash>
	<20090314134017.d0ec1024.billfink@mindspring.com>
	<20090314140857.746dbbf6.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ram.vepa@neterion.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752706AbZCNSou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 14:44:50 -0400
In-Reply-To: <20090314140857.746dbbf6.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Sat, 14 Mar 2009 14:08:57 -0400

> And I believe LRO has been deprecated in favor of GRO.

That's correct.

We should not add any new users of LRO.
