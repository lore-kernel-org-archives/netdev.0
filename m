From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/7] au1000-eth cleanups
Date: Wed, 7 Apr 2010 10:08:49 +0200
Message-ID: <201004071008.49457.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:64281 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab0DGIJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:09:56 -0400
Received: by ewy20 with SMTP id 20so385422ewy.1
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:09:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here comes a serie of 7 cleanups and small enhancements for the Au1000 
ethernet driver.

Florian Fainelli (7):
  au1000-eth: allow driver to be compiled as a module
  au1000-eth: set MODULE_VERSION
  au1000-eth: prefix all functions with au1000_
  au1000-eth: fix checkpatch errors.
  au1000-eth: implement set/get_msglevel
  au1000-eth: Use (dev|netdev|netif)_<level> macro helpers
  au1000-eth: bump to 1.7
