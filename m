From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver
Date: Wed, 23 Aug 2006 17:04:11 -0700
Message-ID: <20060824000411.GA14946@us.ibm.com>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608220038580.18115@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	Rob Mapes <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60636 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S965157AbWHXADi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:03:38 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7O03XtR024676
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 20:03:33 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7O03XVR281172
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 18:03:33 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7O03WPs004403
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 18:03:33 -0600
To: Pradeep Dalvi <pradeep@netxen.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608220038580.18115@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like you have not run the source throught Lindent as previously
requested.  Before you submit the code again, please use the Lindent
script.

I can get the code to ping between two cards.  Will be doing more
testing tomorrow.

-- 
Don Fry
brazilnut@us.ibm.com
