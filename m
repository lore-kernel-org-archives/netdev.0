From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] tg3: Fix APE induced regression
Date: Fri, 12 Oct 2007 01:44:20 -0400
Message-ID: <20071012054420.GD19268@fattire.cabal.ca>
References: <1192153431.4878.219.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:50925 "EHLO
	stout.engsoc.carleton.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbXJLFoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 01:44:24 -0400
Content-Disposition: inline
In-Reply-To: <1192153431.4878.219.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 06:43:50PM -0700, Matt Carlson wrote:
> This patch fixes a bug caused by the recent APE support added for 5761
> devices.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> 

Woot, thanks! This just bit me as I was testing git head on some of my
parisc boxes.

Cheers,
	Kyle
