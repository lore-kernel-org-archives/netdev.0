From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC2][PATCH 7/7] [TFRC]: New rx history code
Date: Thu, 6 Dec 2007 12:07:34 -0200
Message-ID: <20071206140734.GW4653@ghostprotocols.net>
References: <20071206130309.GU4653@ghostprotocols.net> <20071206140225.GD7484@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753099AbXLFOHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 09:07:38 -0500
Content-Disposition: inline
In-Reply-To: <20071206140225.GD7484@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 06, 2007 at 02:02:25PM +0000, Gerrit Renker escreveu:
> | 	The first six patches in this series are unmodified, so if you
> | are OK with them please send me your Signed-off-by.
> Patches [1/7], [2/7], and [6/7] already have a signed-off and there are
> no changes. Just acknowledged [3..5/7], will look at [7/7] now.

OK, please let me know if there are still any problems.

The removal of timestamp insertion in ccid3_hc_rx_insert_options will be
put in another cset.

- Arnaldo
