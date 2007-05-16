From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Tue, 15 May 2007 20:50:56 -0400
Message-ID: <1179276656.4080.48.camel@localhost>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
	 <1179267467.4080.33.camel@localhost>  <1179269317.4080.40.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Max Krasnyansky <maxk@qualcomm.com>,
	Gagan Arneja <gagan@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:61736 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760190AbXEPAvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 20:51:01 -0400
Received: by wr-out-0506.google.com with SMTP id 76so8266wra
        for <netdev@vger.kernel.org>; Tue, 15 May 2007 17:51:01 -0700 (PDT)
In-Reply-To: <1179269317.4080.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-15-05 at 18:48 -0400, jamal wrote:

> I will try to post the e1000 patch tonight or tommorow morning.

I have the e1000 path done; a few features from the 2.6.18 missing
(mainly the one mucking with tx ring pruning on the tx path).
While it compiles and looks right - i havent tested it and wont have
time for another day or so. However, if anyone wants it in its current
form -let me know and i will email you privately.

cheers,
jamal 

