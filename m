From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc2 0/2] minor cleanups for s2io
Date: Wed, 28 Sep 2005 17:50:51 -0400
Message-ID: <09282005175051.10698@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, leonid.grossman@neterion.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751041AbVI1Vyk@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A couple of minor cleanups for the s2io driver:

	-- Use the target length as the third argument to strncpy
	in s2io_ethtool_gdrvinfo()

	-- Add a MODULE_VERSION entry

Patches to follow...
