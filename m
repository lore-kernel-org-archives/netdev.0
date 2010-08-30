From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 [PATCH 0/5] dccp: ccid-2 clean-up; code sharing
 between TCP and DCCP
Date: Mon, 30 Aug 2010 13:46:38 -0700 (PDT)
Message-ID: <20100830.134638.27802080.davem@davemloft.net>
References: <ccid2_and_tcp_code_sharing>
	<1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33361
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755809Ab0H3UqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:46:22 -0400
In-Reply-To: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 07:23:09 +0200

> All patches have been tested to compile independently and are at the top of
> git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree 'dccp').

WHat was this 'dccp' branch based upon?  I tried to pull it into
net-next-2.6 and got lots of unrelated changes and several
conflicts.

If you want me to pull your GIT tree it has to be clean,
against the proper tree, and I should only ever get your
specific changes and absolutely nothing unrealted.

I've applied the 5 patches by hand instead, they all
look fine, thanks!
