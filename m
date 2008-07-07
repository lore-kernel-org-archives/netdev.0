From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] ipv[46]: Fix MD5 signatures for non-linear skbs
Date: Mon, 7 Jul 2008 14:40:33 -0700
Message-ID: <396556a20807071440p58aab414jd622feb4849b977@mail.gmail.com>
References: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
	 <396556a20805301217k293e5718h6bbf02bfe069001@europa>
	 <20080707112237.14fb3284@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:6122 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbYGGVkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:40:35 -0400
Received: by py-out-1112.google.com with SMTP id p76so1028436pyb.10
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 14:40:34 -0700 (PDT)
In-Reply-To: <20080707112237.14fb3284@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 7, 2008 at 11:22 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Patch doesn't apply cleanly to net-next-2.6 tree because of other changes
> so to help the merge, please create a version for that as well.

Yea, that clashes pretty badly with net-next-2.6. Patch for that
coming in a sec.


-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
