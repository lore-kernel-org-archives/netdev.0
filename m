From: Roland Dreier <rdreier@cisco.com>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sat, 10 May 2008 08:53:14 -0700
Message-ID: <adave1mp34l.fsf@cisco.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
	<20080507.141521.193714938.davem@davemloft.net>
	<482498D5.9060008@krogh.cc>
	<20080509.143229.174354251.davem@davemloft.net>
	<4824C936.9000103@krogh.cc> <4824CE43.8060203@hp.com>
	<4824D4C0.10201@krogh.cc> <1210374525.21330.6.camel@lap75545.ornl.gov>
	<48253F33.3000109@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dillowda@ornl.gov>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:14948 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbYEJPxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2008 11:53:15 -0400
In-Reply-To: <48253F33.3000109@krogh.cc> (Jesper Krogh's message of "Sat, 10
	May 2008 08:22:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Ok. It must be x8 then:
 >                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 1

Actually that line is showing the supported capabilities... you want the
second line a few down that shows the actual status.

 - R.
