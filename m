From: David Miller <davem@davemloft.net>
Subject: Re: [BUG-FIX][PATCH 0/2]: recent dccp fixes
Date: Sun, 31 Jan 2010 23:17:32 -0800 (PST)
Message-ID: <20100131.231732.241918500.davem@davemloft.net>
References: <recent-dccp-bug-fixes-jan-2010>
	<1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46985
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475Ab0BAHRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 02:17:19 -0500
In-Reply-To: <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  1 Feb 2010 07:18:05 +0100

> In January there were two dccp commits introducing bugs. Having
> been guilty of ack-ing them, please find below patches to fix
> them.
> 
> Patch #1: fixes a bug resulting from truncating cache name length.
> Patch #2: reverts a commit which introduced a module-loading bug.
> 
> This being bugs, would you please consider this for stable too.
> 
> The test-tree also has been fixed accordingly,
> http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=ready    

Gerrit can you at least CC: the author of the changes
you are reverting?
