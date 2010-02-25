From: Jeff Garzik <jeff@garzik.org>
Subject: ethtool 2.6.33 released
Date: Wed, 24 Feb 2010 22:35:38 -0500
Message-ID: <4B85F00A.2050602@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:61579 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab0BYDfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 22:35:40 -0500
Received: by ywh35 with SMTP id 35so2982531ywh.4
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 19:35:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ethtool version 2.6.33 has been released.

Home page: https://sourceforge.net/projects/gkernel/
Download link: 
https://sourceforge.net/projects/gkernel/files/ethtool/2.6.33/ethtool-2.6.33.tar.gz/download

Release notes:

         This version introduces a new release numbering scheme, based
         on the latest upstream kernel interface supported.

         * Fix: several man page corrections
         * Feature: rx flow hash configuration
         * Feature: report 10000baseT support, where available
         * Feature: report MDI-X status, pause auto-neg, link partner
	  adverts
         * Feature: support additional port types
         * Feature: support arbitrary speeds, faster than 65535 Mb
         * Feature: large and generic receive offload (LRO, GRO) support
         * Feature: option to flash firmware image from specified file
         * Feature: support for block writing of EEPROMs
         * Feature: marvell register dump update
         * Feature: at76c50x-usb, e1000e, igb, ixgbe, r8169 register
	  dump support
         * Cleanup: remove support for RX hasing by port (was removed in
           kernel by 59089d8d162ddcb5c434672e915331964d38a754)
         * Doc: Explicitly ship GPLv2 license, rather than relying
           on autotools to supply it for us (autotools started
	  auto-installing GPLv3 recently)


