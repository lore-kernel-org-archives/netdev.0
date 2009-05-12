From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 0/2] iproute2: Support for CAN network devices
Date: Tue, 12 May 2009 11:42:48 +0200
Message-ID: <20090512094248.439786706@denx.de>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:40520 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757334AbZELJmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 05:42:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

here are the patches for the "ip" program of the iproute2 utility
suite adding support for CAN netlinks.

  1/2) iproute2: Fixes an issue with cross-compilation
  2/2) iproute2: Support for the CAN netlink

The first patch is required to get it cross-compiled.

The patches are based on v2 of the patch series for the Linux kernel
with the subject:

  [PATCH v2 0/7] can: CAN network device driver interface and drivers

posted a few minutes ago:

  http://marc.info/?l=linux-netdev&m=124212048701347&w=2

Please consider these patches for inclusion when the Linux kernel
patches have been accepted.

Thanks,

Wolfgang.

