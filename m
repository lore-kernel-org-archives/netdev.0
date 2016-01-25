From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bonding: Use notifiers for slave link state
 detection
Date: Mon, 25 Jan 2016 10:00:16 -0800 (PST)
Message-ID: <20160125.100016.903047302149190107.davem@davemloft.net>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
	<1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
	<87618083B2453E4A8714035B62D679925051E54D@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zyjzyj2000@gmail.com, mkubecek@suse.cz, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	boris.shteinbock@windriver.com, jay.vosburgh@canonical.com
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbcAYSAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:00:18 -0500
In-Reply-To: <87618083B2453E4A8714035B62D679925051E54D@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Mon, 25 Jan 2016 16:33:37 +0000

> The patch you are referring to has not been accepted in net-next yet.
> If/when that happens you can request it to be ported to the stable tree.

Wrong.

If you want a patch to get submitted to stable, it must be appropriate for
and you must target it to 'net', not 'net-next'.
