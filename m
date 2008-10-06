From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: v2 [PATCH 0/5] dccp: Feature negotiation, Part I - Underlying
	data structures
Date: Mon, 6 Oct 2008 06:14:13 +0200
Message-ID: <20081006041413.GA3762@gerrit.erg.abdn.ac.uk>
References: <20081002.125252.202124982.davem@davemloft.net> <1223111606-5308-1-git-send-email-gerrit@erg.abdn.ac.uk> <20081005.091334.208715265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37119 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750832AbYJFEOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 00:14:21 -0400
Content-Disposition: inline
In-Reply-To: <20081005.091334.208715265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| You have to split up your patches more intelligently, such that they
| are fully bisectable and at each patch point there are no new warnings
| or known bugs added.
| 
OK will do. I understand that this means resubmitting the full set.
