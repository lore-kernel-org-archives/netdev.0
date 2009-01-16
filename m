From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 0/2] PS3: gelic: convert to net_device_ops
Date: Fri, 16 Jan 2009 17:45:51 +0900
Message-ID: <20090116173633.0B69.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>
To: jgarzik@pobox.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms6.Sony.CO.JP ([211.125.136.204]:46383 "EHLO ms6.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761059AbZAPIqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 03:46:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset converts the gelic driver to net_device_ops

	#1	PS3: gelic: convert the ethernet part to net_device_ops
	#2	PS3: gelic: wireless: convert the wireless part to
	  	net_device_ops

regards

-- 
Masakazu Mokuno

