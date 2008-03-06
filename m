From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] ivp4: igmp.c remove __inline__ and old changelog
Date: Thu, 06 Mar 2008 14:25:51 -0800
Message-ID: <1204842351.23455.4.camel@brick>
References: <1204831863.23455.1.camel@brick>
	 <20080306.142319.265152470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:48706 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754329AbYCFW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 17:26:08 -0500
Received: by rn-out-0910.google.com with SMTP id v46so181956rnb.15
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 14:26:04 -0800 (PST)
In-Reply-To: <20080306.142319.265152470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-06 at 14:23 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Thu, 06 Mar 2008 11:31:03 -0800
> 
> > Also move EXPORT_SYMBOL() next to the function they export.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> We have not decided to remove the changelog entries in the networking
> sources.  It might be impolite to remove references to the contributes
> made by individuals during the pre-BK/GIT era where no changelogs were
> kept.

How about I add all the removed text to the changelog for the removal
patch?  If there isn't any agreement on this, just drop it and I'll
submit a patch with just the __inline__ removal and the EXPORT_SYMBOL
movement...or just drop the changelog hunks and apply the rest.

Let me know what your preference is.

Harvey



