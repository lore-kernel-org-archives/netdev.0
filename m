From: Steve.Glendinning@smsc.com
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 09:52:31 +0000
Message-ID: <OFC17C40AC.BA569CF8-ON8025753E.0035C2A6-8025753E.0036542B@smsc.com>
References: <20090114.013006.55972352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	stanley.miao@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3044 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754407AbZANJyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 04:54:14 -0500
In-Reply-To: <20090114.013006.55972352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > David: would it make sense to put this driver patch into the arm
> > tree?
> 
> I plan on taking it via net-2.6

Thanks David, I guess I need to wait until this is merged (and pulled into 
the arm tree) before my arm platform patches can go in?  They break 
compilation without the driver patch.

I'll post the patchset to arm-kernel for review today.

Steve
