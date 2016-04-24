From: Ran Shalit <ranshalit@gmail.com>
Subject: smc911 vs smsc911
Date: Sun, 24 Apr 2016 08:25:15 +0300
Message-ID: <CAJ2oMhKar146axry-1WstORmV2y1Ok+1SEJ1Y=v4jXPK_UEYyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33946 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbcDXFZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 01:25:16 -0400
Received: by mail-io0-f171.google.com with SMTP id 2so155766672ioy.1
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 22:25:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Does anyone can say what's the difference between smc911 and smsc911 ?

On reading the first comments in each file it seems that there is
overlapping between them:

smc911x.c
========
 * This is a driver for SMSC's LAN911{5,6,7,8} single-chip Ethernet devices.


smsc911x.c
===========
 * Supported devices:
 *   LAN9115, LAN9116, LAN9117, LAN9118
 *   LAN9215, LAN9216, LAN9217, LAN9218
 *   LAN9210, LAN9211
 *   LAN9220, LAN9221
 *   LAN89218
 *
  */

Regards,
Ran
