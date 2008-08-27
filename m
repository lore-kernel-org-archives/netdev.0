From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 2/3] enic: add main file with module infrastructure, etc
Date: Tue, 26 Aug 2008 21:15:02 -0700
Message-ID: <adatzd7gkl5.fsf@cisco.com>
References: <adaej4clmo0.fsf@cisco.com>
	<Pine.LNX.4.64.0808262011430.17012@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:37325 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbYH0EPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 00:15:05 -0400
In-Reply-To: <Pine.LNX.4.64.0808262011430.17012@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Tue, 26 Aug 2008 21:03:08 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > LLTX is kind of deprecated for new drivers.  Would be nice to avoid this.
 > 
 > What does kind of deprecated mean?  Is there a performance or
 > maintanance issue with LLTX?

maintenance -- the goal is to remove LLTX entirely, and adding new
drivers that use it is a step in the wrong direction.

 - R.
