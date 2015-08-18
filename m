From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Tue, 18 Aug 2015 12:15:43 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F919413F38@HASMSX110.ger.corp.intel.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <55CD8DDB.5080001@cumulusnetworks.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2389@SJEXCHMB14.corp.ad.broadcom.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F919413D1D@HASMSX110.ger.corp.intel.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2730@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>,
	roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:28912 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752630AbbHRMP4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 08:15:56 -0400
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E2730@SJEXCHMB14.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Prem, 

>I recall that there was a patch proposed to prevent ageing of fdb entried by bridge in kernel, when the fdb entry was added due to >notification by switch device.  Please see:
>http://www.spinics.net/lists/netdev/msg314770.html

>Somehow the patch is not visible in the net-next pull.

It seems that this patch was reverted:
http://lists.openwall.net/netdev/2015/02/05/129
https://lkml.org/lkml/2015/2/11/12

Regards,
Rami Rosen
Intel Corporation
