From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 15:49:26 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B190F2@CHN-SV-EXMX02.mchp-main.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <jbe@pengutronix.de>,
        <sean.wang@mediatek.com>, <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:40143 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755000AbdIFPtk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 11:49:40 -0400
In-Reply-To: <20170906004703.GB27385@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

> What i found is that the Marvell chips don't flood broadcast frames
> between bridged ports. What appears to happen is there is a fdb miss,
> so it gets forwarded to the CPU port for the host to deal with. The
> software bridge when floods it out all ports of the bridge.
Is this IGMP snooping enabled mode in Marvell chip?
