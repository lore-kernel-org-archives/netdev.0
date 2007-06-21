From: jamal <hadi@cyberus.ca>
Subject: Re: [RESEND][PATCH][IPROUTE2]  see SAD info
Date: Thu, 21 Jun 2007 11:12:16 -0400
Message-ID: <1182438736.5017.1.camel@localhost>
References: <1178233781.4068.6.camel@localhost>
	 <20070619162553.2b4babff@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:24385 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbXFUPM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 11:12:26 -0400
Received: by wr-out-0506.google.com with SMTP id q50so487075wrq
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 08:12:25 -0700 (PDT)
In-Reply-To: <20070619162553.2b4babff@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-19-06 at 16:25 -0700, Stephen Hemminger wrote:

> Using current xfrm.h from kernel headers, causes conflicts.
> Instead of XFRMA_SADCNT, it should be using XFRMA_SAD_CNT.
> 

Yeah, that changed in the kernel header. 
If it compiles, it should be fine; thanks Stephen.

cheers,
jamal

