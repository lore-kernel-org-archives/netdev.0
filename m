From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 25/27] e1000e: static analysis tools complain of
 a possible null ptr p dereference
Date: Fri, 10 Dec 2010 12:16:24 -0800 (PST)
Message-ID: <20101210.121624.245389962.davem@davemloft.net>
References: <1291975585-30576-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291985090.24978.17.camel@Joe-Laptop>
	<EA929A9653AAE14F841771FB1DE5A136602D54FD2F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jeffrey.t.kirsher@intel.com, davem@davemleft.org,
	bruce.w.allan@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50219
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754368Ab0LJUP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:15:57 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602D54FD2F@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Fri, 10 Dec 2010 12:35:45 -0700

> Dave, unless this is infringing on some coding style rule, I would request that the patch be applied as is.

I think Ben's request is more than reasonable.  Please make his requested
change.  "continue; break;" looks quite silly to me too.
