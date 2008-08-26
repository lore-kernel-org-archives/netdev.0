From: "\"G\"" <balajig81@gmail.com>
Subject: Kernel Support in Linux PPC
Date: Tue, 26 Aug 2008 21:04:17 +0530
Message-ID: <6dd1343e0808260834h7bc423a9ka47446111cbdb01f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:14282 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915AbYHZPeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 11:34:19 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1321278tic.23
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 08:34:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am developing a Linux Kernel Module which basically would do native
bridging with VLAN and RSTP. The LKM basically would make use of
sk_buff ,net_device, timers, locks etc. I am developing this in i386
platform and the kernel version is 2.6.15.4 and it works fine as of
now. Now i need to move from i386 to PPC architecture with the same
version of the kernel and then move from 2.6.15.4 to 2.6.26 in the PPC
architecture.

I would like to know whether would i face any big surprises/changes
apart from the sk_buff and netdevice data structure changes in the
latest versions of the kernel ?

Thanks for your help

Cheers,
Balaji
