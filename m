From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Fri, 7 Jul 2017 02:56:01 +0200
Message-ID: <20170707005601.GG8810@lunn.ch>
References: <20170628134139.GB12559@lunn.ch>
 <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
 <20170628180008.42059797@cakuba.netronome.com>
 <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706223324.GA24237@lunn.ch>
 <MWHPR12MB1600B8ECA4222A062CDC71C0C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170706231550.GC24237@lunn.ch>
 <MWHPR12MB16009D656DD4408DE4429274C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        "olson@cumulusnetworks.com" <olson@cumulusnetworks.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47378 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752673AbdGGA4N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 20:56:13 -0400
Content-Disposition: inline
In-Reply-To: <MWHPR12MB16009D656DD4408DE4429274C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you choose to think of a cable unplug/plug event as "hot plug", then
> the "reset" is the model that feels right.  But I'll note that this is also
> presupposing what the right model is for users.  This is akin
> to trying to decide what to make for dinner and deciding that a
> hammer is the right tool.  If we end up deciding on Cracked
> Crab (or Tree Nuts for the vegans amongst us), then the
> hammer is quite possibly a good answer.

It also depends on the chef. A skilled chef knows how to use and abuse
a hammer and can make quite good filo pastry using a hammer if need
be.

And when we are talking about SFP modules, we are not talking about
somebody who can just about boiling an egg and put bread in the
toaster.

Anybody using these SFP modules knows a lot about networking, is a
power user, and probably does not rely on plug and pray.

      Andrew
