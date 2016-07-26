From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Mon, 25 Jul 2016 20:34:03 -0600
Message-ID: <ceb825e1-cba5-e252-f8d1-30198797bbb2@cumulusnetworks.com>
References: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	steffen.klassert@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35626 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbcGZCeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 22:34:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id iw10so66824056pac.2
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 19:34:09 -0700 (PDT)
In-Reply-To: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/25/16 6:34 PM, Subash Abhinov Kasiviswanathan wrote:
> We are seeing incorrect routing when tunneling packets over an
> interface and sending it over another interface. This scenario
> worked on 3.18 (and earlier) and failed on 4.4 kernel. The rules
> / routes / policies were the same across kernels.

Can you give an example of your use case -- e.g., commands for others 
(me) to reproduce?
