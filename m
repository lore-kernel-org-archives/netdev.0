From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: Use notifiers for slave link state
 detection
Date: Mon, 25 Jan 2016 16:33:37 +0000
Message-ID: <87618083B2453E4A8714035B62D679925051E54D@FMSMSX105.amr.corp.intel.com>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
 <1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"jay.vosburgh@canonical.com" <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15980 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757317AbcAYQdj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 11:33:39 -0500
In-Reply-To: <1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: zyjzyj2000@gmail.com [mailto:zyjzyj2000@gmail.com]
>Sent: Thursday, January 21, 2016 2:16 AM
>To: zyjzyj2000@gmail.com; mkubecek@suse.cz; vfalico@gmail.com;
>gospo@cumulusnetworks.com; netdev@vger.kernel.org; Shteinbock, Boris (Wind
>River); jay.vosburgh@canonical.com; Tantilov, Emil S
>Subject: [PATCH 1/1] bonding: Use notifiers for slave link state detection
>
>
>Hi, Jay && Emil
>
>Thanks for your hard work. I forget to send this patch to you. Please help
>to review. Thanks a lot.
>
>I think the similar patch is needed in linux kernel 4.4. As such, based on
>linux kernel 4.4, I made this patch. Please comment.

The patch you are referring to has not been accepted in net-next yet.
If/when that happens you can request it to be ported to the stable tree.

Last version I tested seemed to work OK, but Jay mentioned some RCU warnings and 
I was expecting a follow up on it.

Thanks,
Emil
