From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [linux-nics] FIX ME in e1000_82575.c
Date: Mon, 24 Nov 2014 16:32:16 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD653451A92@ORSMSX114.amr.corp.intel.com>
References: <547165BC.2000508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"linux-kernel@vger.kernel.or" <linux-kernel@vger.kernel.or>
To: nick <xerofoify@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61683 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754037AbaKXQcT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 11:32:19 -0500
In-Reply-To: <547165BC.2000508@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure there's much need to actually change the value. It's been the same since 2007 when the log message says, "Removed FIXME comment."

I think someone forgot to remove the second FIXME comment. I'll send a patch.

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565

-----Original Message-----
From: linux-nics-bounces@isotope.jf.intel.com [mailto:linux-nics-bounces@isotope.jf.intel.com] On Behalf Of nick
Sent: Saturday, November 22, 2014 8:43 PM
To: Kirsher, Jeffrey T
Cc: Linux NICS; e1000-devel@lists.sourceforge.net; Vick, Matthew; netdev@vger.kernel.org; Wyborny, Carolyn; linux-kernel@vger.kernel.or
Subject: [linux-nics] FIX ME in e1000_82575.c

Greetings Again Jeff,
I am wondering about sending in a patch to FIX ME in the file, e1000_82575 due to incorrect values in the function, igdb_acquire_swfw_sync_82575. If you or one of the other maintainers at Intel can send me the correct values or a hardware reference for me to find the values, I would be glad to send it a patch fixing these outstanding issues.
Regards Nick
_______________________________________________
Linux-nics mailing list
Linux-nics@intel.com
