From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 19:03:30 -0500
Message-ID: <1266451410.17794.166.camel@bigi>
References: <1266449678.17794.160.camel@bigi>
	 <20100217.154009.78177059.davem@davemloft.net>
	 <1266450553.17794.165.camel@bigi>
	 <20100217.155512.109075614.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:23834 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758046Ab0BRADg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 19:03:36 -0500
Received: by qw-out-2122.google.com with SMTP id 3so171613qwe.37
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 16:03:34 -0800 (PST)
In-Reply-To: <20100217.155512.109075614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 15:55 -0800, David Miller wrote:

> I don't think any sendmsg() method should return 0 when something
> was actually sent.

;-> Ok, I need to call it a day ;->

cheers,
jamal

