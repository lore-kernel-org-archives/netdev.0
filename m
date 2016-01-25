From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: Use notifiers for slave link state
 detection
Date: Mon, 25 Jan 2016 18:37:17 +0000
Message-ID: <87618083B2453E4A8714035B62D679925051F62B@FMSMSX105.amr.corp.intel.com>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
	<1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
	<87618083B2453E4A8714035B62D679925051E54D@FMSMSX105.amr.corp.intel.com>
 <20160125.100016.903047302149190107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"jay.vosburgh@canonical.com" <jay.vosburgh@canonical.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1875 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933685AbcAYShT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:37:19 -0500
In-Reply-To: <20160125.100016.903047302149190107.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, January 25, 2016 10:00 AM
>To: Tantilov, Emil S
>Cc: zyjzyj2000@gmail.com; mkubecek@suse.cz; vfalico@gmail.com;
>gospo@cumulusnetworks.com; netdev@vger.kernel.org; Shteinbock, Boris (Wind
>River); jay.vosburgh@canonical.com
>Subject: Re: [PATCH 1/1] bonding: Use notifiers for slave link state
>detection
>
>From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>Date: Mon, 25 Jan 2016 16:33:37 +0000
>
>> The patch you are referring to has not been accepted in net-next yet.
>> If/when that happens you can request it to be ported to the stable tree.
>
>Wrong.
>
>If you want a patch to get submitted to stable, it must be appropriate for
>and you must target it to 'net', not 'net-next'.

Yeah that came out wrong. I was just trying to point out that this patch
is a port to 4.4 kernel of a test patch from Jay that hasn't even gotten
into the net/net-next trees yet.

Thanks,
Emil
