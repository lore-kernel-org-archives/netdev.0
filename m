From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ivp4: igmp.c remove __inline__ and old changelog
Date: Thu, 06 Mar 2008 14:23:19 -0800 (PST)
Message-ID: <20080306.142319.265152470.davem@davemloft.net>
References: <1204831863.23455.1.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759865AbYCFWXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 17:23:21 -0500
In-Reply-To: <1204831863.23455.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 06 Mar 2008 11:31:03 -0800

> Also move EXPORT_SYMBOL() next to the function they export.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

We have not decided to remove the changelog entries in the networking
sources.  It might be impolite to remove references to the contributes
made by individuals during the pre-BK/GIT era where no changelogs were
kept.
