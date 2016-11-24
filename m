From: Stefan Eichenberger <eichest@gmail.com>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Thu, 24 Nov 2016 22:14:49 +0100
Message-ID: <20161124211449.GB2246@eichest-notebook>
References: <20161122150754.GF2691@lunn.ch>
 <20161122164721.4103-1-stefan.eichenberger@netmodule.com>
 <20161124.152921.1374820040756654804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        stefan.eichenberger@netmodule.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:34638 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941269AbcKXVO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:14:58 -0500
Received: by mail-wj0-f196.google.com with SMTP id xy5so4055766wjc.1
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 13:14:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161124.152921.1374820040756654804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On Thu, Nov 24, 2016 at 03:29:21PM -0500, David Miller wrote:
> From: Stefan Eichenberger <eichest@gmail.com>
> Date: Tue, 22 Nov 2016 17:47:21 +0100
> 
> > Add support for the MV88E6097 switch. The change was tested on an Armada
> > based platform with a MV88E6097 switch.
> > 
> > Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
> 
> Applied to net-next, thanks.

I'm afraid this is the wrong patch version, Andrew and Vivien had some
findings, this would be the correct patch series that include all
necessary changes:
http://marc.info/?l=linux-netdev&m=147993563215981&w=2
http://marc.info/?l=linux-netdev&m=147993580216027&w=2
http://marc.info/?l=linux-netdev&m=147993607616121&w=2

Sorry for the confusion, I did a mess
Stefan
