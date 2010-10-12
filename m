From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/6] dccp: miscellaneous fixes and helper
 functions
Date: Tue, 12 Oct 2010 11:45:48 -0700 (PDT)
Message-ID: <20101012.114548.189717363.davem@davemloft.net>
References: <dccp_misc_fixes_and_helper_functions___a_set_of_six_patches_sent_today>
	<1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38805
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757362Ab0JLSp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 14:45:26 -0400
In-Reply-To: <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 12 Oct 2010 07:15:45 +0200

>  Patch #1: fixes two problems in the DCCP  (AWL/SWL) window-size adjustment.
>  Patch #2: refactors the connect_init() function by combining related code.
>  Patch #3: removes an never-user argument from the CCID tx function.
>  Patch #4: provides a function to generalize the data-loss condition 
>            (patch originally came from the ccid-4 subtree).
>  Patch #5: schedules an Ack as carrier for a pending timestamp echo.
>  Patch #6: tidies up the format of DCCP per-connection warnings.
> 
> The set has also been placed into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Looks good, pulled, thanks!
