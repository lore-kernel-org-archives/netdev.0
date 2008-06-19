From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [Security] [PATCH 0/3 2.6.27] cxgb3i: Add iSCSI driver
Date: Thu, 19 Jun 2008 08:45:43 -0700
Message-ID: <8A71B368A89016469F72CD08050AD33402F43B5E@maui.asicdesigners.com>
References: <8A71B368A89016469F72CD08050AD334D71285@maui.asicdesigners.com> <8A71B368A89016469F72CD08050AD334D7128B@maui.asicdesigners.com> <20080619065212.GA9107@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <michaelc@cs.wisc.edu>, "Divy Le Ray" <divy@chelsio.com>,
	<netdev@vger.kernel.org>, <security@kernel.org>,
	<open-iscsi@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>
To: "Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24061 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbYFSPqr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 11:46:47 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg,

We'd like to export security_inet_conn_established() from
security/security.c.

Thanks.
Karen

-----Original Message-----
From: Greg KH [mailto:greg@kroah.com] 
Sent: Wednesday, June 18, 2008 11:52 PM
To: Karen Xie
Cc: michaelc@cs.wisc.edu; Divy Le Ray; netdev@vger.kernel.org;
security@kernel.org; open-iscsi@googlegroups.com;
linux-kernel@vger.kernel.org; linux-scsi@vger.kernel.org
Subject: Re: [Security] [PATCH 0/3 2.6.27] cxgb3i: Add iSCSI driver

On Wed, Jun 18, 2008 at 10:10:00PM -0700, Karen Xie wrote:
> 
> Please review the iSCSI drivers for Chelsio CXGB3 (S3XX) devices.  

Is there some reason you send this to security@kernel.org?

confused,

greg k-h
