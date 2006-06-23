From: Jeff Garzik <jeff@garzik.org>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Fri, 23 Jun 2006 17:40:49 -0400
Message-ID: <449C5FE1.2030809@garzik.org>
References: <0BB3E5E7462EEA4295BC02D49691DC071769A2@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25011 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1752094AbWFWVkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 17:40:53 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC071769A2@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
>> 9) [minor] "N/A" appears to be an inaccurate value for fw_version in 
>> ql_get_drvinfo()
> 
> Does anyone know what would be appropriate for this ethtool command?  My
> device does not use firmware.  I took the "N/A" idea from e1000 and
> skge.

It does both ethernet and iSCSI entirely in silicon?

Is there an easy way to get silicon rev?

	Jeff



