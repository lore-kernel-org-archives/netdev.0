From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] net: smsc911x: Remove multiple exit points from
 smsc911x_open
Date: Thu, 1 Sep 2016 22:43:48 +0200
Message-ID: <20160901204348.GA16864@lunn.ch>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-2-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com, will.deacon@arm.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757193AbcIAVXy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:54 -0400
Content-Disposition: inline
In-Reply-To: <1472760909-19688-2-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 03:15:06PM -0500, Jeremy Linton wrote:
> Rework the error handling in smsc911x open in preparation
> for the mdio startup being moved here.
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
