From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Notifier for features change? (related to Ethernet Bridging: Enable
 Hardware Checksumming)
Date: Fri, 20 May 2005 10:17:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505201014340.12681@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Because bridge can change features based on slaves features,
may I implement NETDEV_FEAT_CHANGE?

It will be used to recompute bridge features when a slave ones are 
changed.

Thank you.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
