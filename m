From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: ethtool 1.6 released
Date: Thu, 20 Jun 2002 05:38:26 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <aes7vr$clj$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a feature release, with no bug fixes since version 1.5.  It 
supports the new features in recent ethtool API changes: control of 
interrupt coalescing, and many diagnostic/debugging commands.

Download from
http://prdownloads.sourceforge.net/gkernel/ethtool-1.6.tar.gz

NEWS file:


Version 1.6 - June 20, 2002

* Feature: Support e1000 register dumps
* Feature: Support RealTek RTL-8139C+ and RTL-8169 register dumps
* Feature: Support coalescing config (ETHTOOL_[GS]COALESCE)
* Feature: Support ring param config (ETHTOOL_[GS]RINGPARAM)
* Feature: Support pause param config (ETHTOOL_[GS]PAUSEPARAM)
* Feature: Support physical NIC identification (ETHTOOL_PHYS_ID)
* Feature: Support NIC self-testing (ETHTOOL_TEST)
* Feature: Support NIC checksum/scatter-gather enable/disable 
(ETHTOOL_[GS]RXCSUM, ETHTOOL_[GS]TXCSUM, ETHTOOL_[GS]SG)
