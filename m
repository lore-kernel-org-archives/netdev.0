From: Bill Gatliff <bgat@billgatliff.com>
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on
 RealView
Date: Tue, 04 Nov 2008 14:25:31 -0600
Message-ID: <4910AFBB.6080506@billgatliff.com>
References: <OFB1CA2244.82F9DB1F-ON802574F7.0058714B-802574F7.005913A3@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Catalin Marinas <catalin.marinas@arm.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Ian.Saturley@smsc.com, netdev@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from venus.billgatliff.com ([209.251.101.201]:55912 "EHLO
	venus.billgatliff.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbYKDUZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:25:30 -0500
In-Reply-To: <OFB1CA2244.82F9DB1F-ON802574F7.0058714B-802574F7.005913A3@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve.Glendinning@smsc.com wrote:
> Hi Jeff,
> 
> Russell's was the last response on this subject, so I guess there are no 
> strong objections?
> 
> If I add the missing features (to bring the smsc911x driver up to feature 
> parity with smc911x) before the next merge window, would you accept a 
> patchset to add it and deprecate the existing driver?

By "deprecate" you mean "switch users over to the new driver"?


b.g.
-- 
Bill Gatliff
bgat@billgatliff.com
