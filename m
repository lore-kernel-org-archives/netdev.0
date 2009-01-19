From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] dccp: Initialisation framework for feature
 negotiation
Date: Sun, 18 Jan 2009 21:39:58 -0800 (PST)
Message-ID: <20090118.213958.214434810.davem@davemloft.net>
References: <20090104.214605.153723453.davem@davemloft.net>
	<1232184993-9927-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1232184993-9927-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36224
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751837AbZASFj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:39:56 -0500
In-Reply-To: <1232184993-9927-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Jan 2009 10:36:30 +0100

> This initialises feature negotiation from two tables, which are in turn are
> initialised from sysctls.
> 
> As a novel feature, specifics of the implementation (e.g. that short seqnos
> and ECN are not yet available) are advertised for robustness.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied for 2.6.30.
