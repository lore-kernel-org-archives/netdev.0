From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 1/2] net headers: cleanup dcbnl.h
Date: Fri, 27 Feb 2009 22:13:05 +0100
Message-ID: <20090227211305.GA12654@uranus.ravnborg.org>
References: <20090227200136.31557.53143.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Leech <christopher.leech@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:43173 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbZB0VLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 16:11:12 -0500
Content-Disposition: inline
In-Reply-To: <20090227200136.31557.53143.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 12:01:36PM -0800, Chris Leech wrote:
> 1) add an include for <linux/types.h>
> 2) change dcbmsg.dcb_family from unsigned char to __u8 to be more
>    consistent with use of kernel types
> 
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
Thanks Chris.

Acked-by: Sam Ravnborg <sam@ravnborg.org>

	Sam
