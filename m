From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/pch_gbe: supports eg20t ptp clock
Date: Mon, 05 Mar 2012 00:57:09 -0500 (EST)
Message-ID: <20120305.005709.1597475617000728984.davem@davemloft.net>
References: <1330926377-11531-1-git-send-email-tshimizu818@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, lucas.demarchi@profusion.mobi,
	mirq-linux@rere.qmqm.pl, paul.gortmaker@windriver.com,
	toshiharu-linux@dsn.okisemi.com, jdmason@kudzu.us,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com
To: tshimizu818@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab2CEF5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 00:57:21 -0500
In-Reply-To: <1330926377-11531-1-git-send-email-tshimizu818@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So how the heck is this supposed to work?

You post a patch for the e20tp clock source, you don't CC: netdev.

Then you post this network driver patch which depends upon that on
and you do CC: netdev.

You've made it impossible for me to apply them both properly into my
tree so that the dependency goes in.
