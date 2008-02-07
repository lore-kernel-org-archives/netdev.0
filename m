From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 0/7] PS3: gelic: gelic updates and wireless support
Date: Thu, 07 Feb 2008 19:57:20 +0900
Message-ID: <20080207195151.AD3D.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:49302 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbYBGK53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 05:57:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This set is a collection of patches I submitted before in this ML on
last December and a patch that adds the wireless support to PS3.

The wireless bit (#7) is already ACKed by John <linville@tuxdriver.com>
and Dan <dcbw@redhat.com>.  The ethernet bits have been reviewed and
have no obvious outstanding comments.

Please apply for 2.6.25.

	[1] PS3: gelic: Fix the wrong dev_id passed
	[2] PS3: gelic: Add endianness macros
	[3] PS3: gelic: Code cleanup
	[4] PS3: gelic: Remove duplicated ethtool handlers
	[5] PS3: gelic: Add support for port link status
	[6] PS3: gelic: Add support for dual network interface
	[7] PS3: gelic: Add wireless support for PS3


-- 
Masakazu MOKUNO

