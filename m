From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] dccp: Debugging functions for feature negotiation
Date: Sun, 18 Jan 2009 21:40:33 -0800 (PST)
Message-ID: <20090118.214033.84916995.davem@davemloft.net>
References: <1232184993-9927-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<1232184993-9927-4-git-send-email-gerrit@erg.abdn.ac.uk>
	<1232184993-9927-5-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755653AbZASFkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:40:31 -0500
In-Reply-To: <1232184993-9927-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Jan 2009 10:36:33 +0100

> Since all feature-negotiation processing now takes place in feat.c, functions
> for producing verbose debugging output are concentrated there.
> 
> New functions to print out values, entry records, and options are provided,
> and also a macro is defined to not always have the function name in the
> output line.
> 
> Thanks a lot to Wei Yongjun and Giuseppe Galeota for help and discussion with an
> earlier revision of this patch.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied for 2.6.30
