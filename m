From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/3] dt-binding: net: sfp binding documentation
Date: Wed, 30 Aug 2017 16:58:29 +0200
Message-ID: <20170830145829.GA22289@lunn.ch>
References: <d1e64c5752ef0dd5c5b543c2d4c3ef1783318173.1504086672.git.baruch@tkos.co.il>
 <7ae5d883fd038cf518949b0aa9cbe5369e2a1851.1504086672.git.baruch@tkos.co.il>
 <89261369-d97c-a78c-5a21-a269b2c7e513@cogentembedded.com>
 <20170830111118.wy62va6sjzsxrgoo@tarshish>
 <c3e8af44-bf58-81d7-bd51-d2538dcd41d9@cogentembedded.com>
 <20170830112557.dhcl3pv7gmuzg22v@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45152 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbdH3O6k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 10:58:40 -0400
Content-Disposition: inline
In-Reply-To: <20170830112557.dhcl3pv7gmuzg22v@tarshish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > >     Your example shows there's GPIO phandle *and* specifier.
> > > 
> > > Would "GPIO specifier" be enough here?
> > 
> >    No, specifier is the cells following GPIO (or any other) phandle.
> 
> So this should be "GPIO phandle and specifier of ...", is that correct?
> 
> I have found very few (< 4) occurrences of this language in (lots of) '-gpios' 
> property descriptions under Documentation/devicetree/bindings/. Is this a new 
> requirement?

Sometimes it is just easier to refer to another document:

GPIO, as defined in Documentation/devicetree/binding/gpio/gpio.txt

      Andrew
