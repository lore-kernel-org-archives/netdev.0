From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: IXGBE driver indicates "not enough MMIO resources for SR-IOV"
Date: Wed, 17 Aug 2011 14:38:13 +0900
Message-ID: <4E4B53C5.7030802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f170.google.com ([209.85.210.170]:44258 "EHLO
	mail-iy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab1HQFiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 01:38:18 -0400
Received: by iye16 with SMTP id 16so1228222iye.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2011 22:38:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone

When I set SR-IOV function in driver base on intel ixgbe,
the driver shows error message "not enough MMIO resources for SR-IOV".
My cpu is XEON E5450.
I set Intel Virutualization Technology option enable in BIOS.

How can I fix this problem?

Thanks in advance

Best Regards,
J.Hwan Kim

