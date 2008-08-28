From: Wenji Wu <wenji@fnal.gov>
Subject: Re: about Linux adaptivly adjusting ssthresh
Date: Wed, 27 Aug 2008 19:53:12 -0500
Message-ID: <fb62ce3717a7.48b5b0a8@fnal.gov>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net>
 <000001c90852$a1c19a50$a05ee183@D2GT6T71>
 <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:56591 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037AbYH1AzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 20:55:00 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0K6A00986D4OK1@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Wed, 27 Aug 2008 19:53:12 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008082719531224067 for
 <netdev@vger.kernel.org>; Wed, 27 Aug 2008 19:53:12 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0K6A00C01CWN8Z@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Wed, 27 Aug 2008 19:53:12 -0500 (CDT)
In-reply-to: <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> A little more detail would be helpful.  Are you referring to caching
> ssthresh between connections, or something going on during a
> connection?  Various congestion control modules use ssthresh
> differently, so a comprehensive answer would be difficult.


Thanks John, I am referring to the adaptive ssthresh adjusting during a connection.

thanks,

wenji
