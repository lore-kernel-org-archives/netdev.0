From: <zyjzyj2000@gmail.com>
Subject: [PATCH V5] ixgbe: synchronize link_up and link_speed of a slave
Date: Thu, 31 Dec 2015 13:04:54 +0800
Message-ID: <1451538295-15823-1-git-send-email-zyjzyj2000@gmail.com>
References: <7EED4F91-2DE5-407F-BA6A-681ED57650E4@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <venkat.viswanathan@windriver.com>,
	<Boris.Shteinbock@windriver.com>, <Vincent.Bourg@windriver.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:56888 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbbLaFEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Dec 2015 00:04:52 -0500
In-Reply-To: <7EED4F91-2DE5-407F-BA6A-681ED57650E4@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all

Thanks for the suggestions from Rustad, Mark D.
According to his suggestions, the logs and source code are simplified.

Zhu Yanjun
