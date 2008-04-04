From: Wenji Wu <wenji@fnal.gov>
Subject: A Linux TCP SACK Question
Date: Thu, 03 Apr 2008 21:54:22 -0700
Message-ID: <fc471cb97cfd.47f5520e@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:56832 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbYDDGMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 02:12:07 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYS00INFAYD6H@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Thu, 03 Apr 2008 23:54:23 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040323542300166 for
 <netdev@vger.kernel.org>; Thu, 03 Apr 2008 23:54:23 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYS00401AXASX@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Thu, 03 Apr 2008 23:54:23 -0500 (CDT)
Received: from fnal.gov (imap2.fnal.gov [131.225.111.7])
 by mailgw2.fnal.gov (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28
 2005)) with ESMTP id <0JYS0019MAYMIT@mailgw2.fnal.gov> for
 netdev@vger.kernel.org; Thu, 03 Apr 2008 23:54:22 -0500 (CDT)
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Could any body help me out with Linux TCP SACK? Thanks in advance.

I run iperf to send traffic from sender to receiver. and add packet reordering in both forward and reverse directions. I found when I turn off the SACK/DSACK option, the throughput is better than with the SACK/DSACK on? How could it happen in this way? did anybody encounter this phenomenon before?


thanks,

wenji
