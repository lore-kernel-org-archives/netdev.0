From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: small driver update, including switchdev doc update
Date: Tue,  5 Apr 2016 10:20:01 +0200
Message-ID: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	corbet@lwn.net, sfeldma@gmail.com, nicolas.dichtel@6wind.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36103 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbcDEIUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:20:08 -0400
Received: by mail-wm0-f45.google.com with SMTP id 127so15720850wmu.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 01:20:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (3):
  mlxsw: spectrum: Reduce number of supported 802.1D bridges
  switchdev: Use switch ID in suggested udev rule
  mlxsw: spectrum: Add support for physical port names

 Documentation/networking/switchdev.txt         | 28 ++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 45 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  2 +-
 3 files changed, 57 insertions(+), 18 deletions(-)

-- 
2.5.5
