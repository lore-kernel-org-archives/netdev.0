From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2 2.6.29] cxgb3 - manage private iSCSI IP address
Date: Tue, 16 Dec 2008 15:49:46 -0800 (PST)
Message-ID: <20081216.154946.129834909.davem@davemloft.net>
References: <1229189304.3465.13.camel@localhost.localdomain>
	<8A71B368A89016469F72CD08050AD33403FF3179@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org
To: kxie@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755811AbYLPXto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:49:44 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD33403FF3179@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Karen Xie" <kxie@chelsio.com>
Date: Tue, 16 Dec 2008 10:04:20 -0800

> This net patch is independent of any iscsi/scsi changes. 

It's totally corrupted with line wraps so I can't even
check if it applies cleanly to net-next-2.6 or anything
like that.

I can't tell you how frustrating such carelessness is.  When
I process 40+ patches a day I simply can't run into problems
like this.  Really... it just doesn't work if people do this.

You also keep using "linux-netdev", that's not the mailing
list name, it's just plain "netdev".  I've fixed that in
the CC: list.

Anyways.  Feel free to push this in via the scsi tree if
that helps with the conflicts.
