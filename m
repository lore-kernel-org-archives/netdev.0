From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: "MD5 Hash NOT expected but found" ..
Date: Tue, 29 Jul 2008 09:37:46 -0700
Message-ID: <396556a20807290937l7ed075dbl6ad9d0af8164f263@mail.gmail.com>
References: <20080729160430.GQ3820@mea-ext.zmailer.org>
	 <20080729091615.11595272@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Matti Aarnio" <matti.aarnio@zmailer.org>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:14706 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbYG2Qhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 12:37:48 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5123378rvb.1
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 09:37:46 -0700 (PDT)
In-Reply-To: <20080729091615.11595272@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 9:16 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Somebody is trying to connect with MD5 option.

The message was there before the rework in net-2.6 and so I kept it at the time.

> This kernel message is too verbose for production systems.

Another person has expressed the same opinion and, in my current code,
I've already removed it. I'll submit a patch. If someone had a good
reason for including it in the first place they can speak up.


Cheers

AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
