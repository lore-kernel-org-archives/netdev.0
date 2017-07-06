From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 22:37:14 +0000
Message-ID: <MWHPR12MB1600BB2E71001D9C3E0448DBC8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>
        <20170628180008.42059797@cakuba.netronome.com>
        <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170706120214.6076be46@cakuba.netronome.com>
 <MWHPR12MB16008B0A63E099591C26C7E8C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>,<9BBC4E0CF881AA4299206E2E1412B6265049232F@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Dustin Byford <dustin@cumulusnetworks.com>,
        Andrew Lunn <andrew@lunn.ch>,
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
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
        Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0116.outbound.protection.outlook.com ([104.47.33.116]:5280
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751723AbdGFWhS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 18:37:18 -0400
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6265049232F@ORSMSX102.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Wyborny, Carolyn <carolyn.wyborny@intel.com>
| Sent: Thursday, July 6, 2017 3:16 PM
|=20
| Agree with your points generally, but other networking hw vendors have
| dealt with this since SFP variant and other modules arrived on the scene.=
=A0

The only case of this of which I'm aware is the SFP+ RJ45 1Gb/s
Transceiver Module.  But yes, that presaged what we're looking at
now as a much simpler example.

Casey=
