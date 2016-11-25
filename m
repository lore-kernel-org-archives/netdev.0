From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Fri, 25 Nov 2016 03:03:24 +0100
Message-ID: <20161125020324.GA26806@lunn.ch>
References: <20161122150754.GF2691@lunn.ch>
 <20161122164721.4103-1-stefan.eichenberger@netmodule.com>
 <20161124.152921.1374820040756654804.davem@davemloft.net>
 <20161124211449.GB2246@eichest-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, stefan.eichenberger@netmodule.com
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54980 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbcKYCDa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 21:03:30 -0500
Content-Disposition: inline
In-Reply-To: <20161124211449.GB2246@eichest-notebook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 10:14:49PM +0100, Stefan Eichenberger wrote:
> Hi David
> 
> On Thu, Nov 24, 2016 at 03:29:21PM -0500, David Miller wrote:
> > From: Stefan Eichenberger <eichest@gmail.com>
> > Date: Tue, 22 Nov 2016 17:47:21 +0100
> > 
> > > Add support for the MV88E6097 switch. The change was tested on an Armada
> > > based platform with a MV88E6097 switch.
> > > 
> > > Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
> > 
> > Applied to net-next, thanks.
> 
> I'm afraid this is the wrong patch version, Andrew and Vivien had some
> findings, this would be the correct patch series that include all
> necessary changes:

Hi Stefan

David does not remove patches once they are accepted. Please send
followup patches which convert the current state to what we actually
want.

	Andrew
