From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/2] sky2: patches for 2.6.16 -stable
Date: Wed, 21 Feb 2007 16:04:41 -0800
Message-ID: <20070222000441.469009000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58914 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423102AbXBVAHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 19:07:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I compared the current sky2 driver against the version in 2.6.16.40.
These were the only two patches that should be added.
They both relate to dual port boards, and not to many people have
them.

--
Stephen Hemminger <shemminger@linux-foundation.org>

