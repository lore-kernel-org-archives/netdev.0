From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] dccp: Registration routines for changing feature
 values
Date: Mon, 10 Nov 2008 13:16:03 -0800 (PST)
Message-ID: <20081110.131603.182636098.davem@davemloft.net>
References: <1225950014-6337-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751393AbYKJVQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:16:03 -0500
In-Reply-To: <1225950014-6337-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:12 +0100

> Two registration routines, for SP and NN features, are provided by this patch,
> replacing a previous routine which was used for both feature types.
> 
> These are internal-only routines and therefore start with `__feat_register'.
> 
> It further exports the known limits of Sequence Window and Ack Ratio as symbolic
> constants.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
