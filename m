From: s prasad <sprasad.kandregula@gmail.com>
Subject: Fwd: Need help about AR8327 Ethernet Driver
Date: Mon, 27 Jul 2015 12:16:52 -0400
Message-ID: <CAJa-X96YSj4TkZBkPZ-wF80Mjw4D237reRgtL0hkqpFy-RugQA@mail.gmail.com>
References: <CAJa-X96OijRZS4G5eKRUR0c3QG8zpYVJj53t68m_z3O1fgf8Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJa-X96OijRZS4G5eKRUR0c3QG8zpYVJj53t68m_z3O1fgf8Ow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi  All,

I am trying to sniff Ethernet data using AR8327 chip-set from other
Ethernet device KSZ8895, which gives multiplexed TX and RX data of
monitoring data of another device.

If I am using devices like DUB-E100(D-Link), am able capture data from
KSZ8895(Multiplexed TX and Rx Ethernet data).

But If I am trying to sniff Ethernet data using AR8327 Chipset(Router
TP-Link AC 1750), then am not able to capture data. But in
(switch/port) port registers showing correct values.

Am using tcpdump to check data on specific interface. When I am using
DUB-E100(D-Link) or passive Ethernet sniffer(Either Rx or Tx packets)
then able to see whole data, but not with AR8327 Chipset.

My environment is given below:
Router: TPLink AC 1750
Ethernet data coming from KSZ8895 (Multiplexed Tx and RX of another device)
"OpenWRT" Environment

Can somebody through where should I look to solve my issue.

Thanks and Regards,
S Prasad


-- 
S Prasad Kandregula
