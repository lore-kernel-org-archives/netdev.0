From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Thu, 17 Apr 2008 09:36:13 -0400
Message-ID: <1208439373.4420.38.camel@localhost>
References: <4806C501.20300@tiscali.nl>
	 <20080416.213712.78410382.davem@davemloft.net> <4806D847.2030806@trash.net>
	 <1208437113.4420.34.camel@localhost>  <48074C4E.6060400@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, 12o3l@tiscali.nl,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:41649 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbYDQNgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 09:36:18 -0400
Received: by an-out-0708.google.com with SMTP id d31so16402and.103
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 06:36:17 -0700 (PDT)
In-Reply-To: <48074C4E.6060400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-17-04 at 15:10 +0200, Patrick McHardy wrote:

> Basic validity checks are always performed. But I agree, better
> to provide a good example.

Thanks Patrick. 
I just noticed the iproute2 piece is missing - probably sitting
somewhere in my old laptop if i can find it.
Roel, you wanna take a crack at that too?

cheers,
jamal

