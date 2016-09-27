From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH v3 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 27 Sep 2016 16:26:59 +0200
Message-ID: <20160927142659.GC10776@microsemi.com>
References: <1474984075-12312-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160927141633.GJ28432@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <f.fainelli@gmail.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0087.outbound.protection.outlook.com ([104.47.40.87]:48306
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933520AbcI0OnV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 10:43:21 -0400
Content-Disposition: inline
In-Reply-To: <20160927141633.GJ28432@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> > +Optional properties:
> > +- vsc8531,edge-rate  : Edge rate sets the drive strength of the MAC
> > +                       interface output signals.  Changing the drive
> > +                       strength will affect the edge rate of the output
> > +                       signal.
> 
> Are we specifying a rate or a strength? It is called edge-rate, so it
> expect it to be a rate, mV/pS or something similar.
I do not know - sorry.

If it is a hard requirement to document these settings using physical units then
we need to requist some help from the HW team.

I will forward this to the HW team - but it will properly take a few days to get
a decent answer.

Best regards
Allan W. Nielsen
