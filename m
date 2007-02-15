From: "Tony Chung" <tchung@appliedidentity.com>
Subject: sk98lin: 2 Pair Downshift detected
Date: Thu, 15 Feb 2007 12:49:26 -0800
Message-ID: <626DF2B4C31B7D4CA3820BD8245FC4AA0170EADA@AIEX01.ai.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.appliedidentity.com ([71.4.61.228]:20165 "EHLO
	AIEX01.ai.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161289AbXBOVGt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 16:06:49 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I got the following message:

        Class:  Hardware failure
        Nr:  0x270
        Msg:  2 Pair Downshift detected

It is from the sk98lin driver and my research indicated that it may be
caused by bad Ethernet cable.  The gigabit port is now became 100Mbps.

My questions are:
1. What is 0x270 mean? Is there any link or reference for it?
2. How do you recover from it (i.e. negotiate back to 1000Mbps)?
Reboot? Reload the driver?  Can the driver do it automatically?


Thanks.
- Tony
