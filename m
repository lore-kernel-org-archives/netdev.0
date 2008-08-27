From: Wenji Wu <wenji@fnal.gov>
Subject: about Linux adaptivly adjusting ssthresh
Date: Wed, 27 Aug 2008 09:38:54 -0500
Message-ID: <000001c90852$a1c19a50$a05ee183@D2GT6T71>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: 'David Miller' <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:55563 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbYH0PjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 11:39:01 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0K69001L2KB540@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Wed, 27 Aug 2008 09:39:00 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008082709385911763 for
 <netdev@vger.kernel.org>; Wed, 27 Aug 2008 09:38:59 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0K6900A01KLOGF@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Wed, 27 Aug 2008 09:39:00 -0500 (CDT)
In-reply-to: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all, 

Could anybody help me out with Linux adaptively adjusting ssthresh? Thanks
in advance.

I understand that the latest Linux is able to adaptively adjust ssthresh to
avoid retransmission. Could anybody tell me which algorithms have been
implemented for the adaptive ssthresh adjust? 

Thanks,

wenji


