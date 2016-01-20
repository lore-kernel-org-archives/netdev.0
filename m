From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] bonding: Use notifiers for slave link state detection
Date: Wed, 20 Jan 2016 13:13:52 +0800
Message-ID: <1453266833-28386-1-git-send-email-zyjzyj2000@gmail.com>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <zyjzyj2000@gmail.com>, <mkubecek@suse.cz>, <vfalico@gmail.com>,
	<gospo@cumulusnetworks.com>, <netdev@vger.kernel.org>,
	<boris.shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63492 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933267AbcATFMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 00:12:50 -0500
In-Reply-To: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Jay && Emil

Thanks for your hard work.

I think the similar patch is needed in linux kernel 4.4. As such, based on linux kernel 4.4, I made this patch. Please comment.

Best Regards!
Zhu Yanjun
