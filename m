From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 1/1] net: phy: Add edge-rate, mac-if, read, write func
 to Microsemi PHYs.
Date: Tue, 9 Aug 2016 14:32:42 -0700
Message-ID: <99765218-ff64-bfe4-a04d-aa17e652758b@gmail.com>
References: <20160808134325.GA4376@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Allan.Nielsen@microsemi.com
To: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34422 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbcHIVco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:32:44 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so1511212pfb.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:32:44 -0700 (PDT)
In-Reply-To: <20160808134325.GA4376@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2016 06:43 AM, Nagaraju Lakkaraju wrote:
> crosemi PHYsBcc: 
> Subject: [PATCH v1 1/1]  net: phy: Add edge-rate, mac-if, read, write func to
> Reply-To: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com> 
> 
> Hello,
> 
> As part of 2nd patch, Add Edge rate control, MAC Interface, Read and write driver functions add for Microsemi PHYs.
> 
> Please review and send your comments.

First thing is to get the initial patch accepted, which is *not* the
case yet, then you can submit incremental changes using the accepted
driver as a baseline.
-- 
Florian
