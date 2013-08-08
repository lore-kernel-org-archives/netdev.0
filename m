From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Preferred method for configuration
Date: Thu, 08 Aug 2013 07:32:14 +0200
Message-ID: <52032D5E.6070307@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:56213 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275Ab3HHFbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 01:31:51 -0400
Received: from [172.17.131.45] (unknown [172.17.131.45])
	by mailgw.hhi.fraunhofer.de (Postfix) with ESMTP id D6D6D1868024
	for <netdev@vger.kernel.org>; Thu,  8 Aug 2013 07:31:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm developing a NIC driver and currently export some custom 
configuration settings and actions (e.g. enabling a loopback mode) via 
sysfs. However I read about ioctl() and configfs and am now confused as 
to what the preferred/expected method is for new drivers.

Best regards.
