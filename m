From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Add PHY IRQ support to the 'sh_eth' driver
Date: Fri, 20 Dec 2013 01:38:09 +0300
Message-ID: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   This patchset adds support for passing PHY's IRQ to the 'sh_eth' driver from
the platform code and removes now useless code that hinders the PHY IRQ handing
by philib.

[1/2] sh_eth: add PHY IRQ to platform data
[2/2] sh_eth: do not reset PHY needlessly

WBR, Sergei
