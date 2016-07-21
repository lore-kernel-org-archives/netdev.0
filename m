From: Magnus Bergroth <bergroth@nordu.net>
Subject: Re: iproute2 mpls max labels
Date: Thu, 21 Jul 2016 21:43:07 +0200
Message-ID: <579125CB.3030201@nordu.net>
References: <578A7BF0.2020107@nordu.net> <57911A26.3080203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Shearman <rshearma@brocade.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e-mailfilter02.sunet.se ([192.36.171.202]:48746 "EHLO
	e-mailfilter02.sunet.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbcGUTnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 15:43:21 -0400
In-Reply-To: <57911A26.3080203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Roopa Prabhu <mailto:roopa@cumulusnetworks.com>
> 21 juli 2016 20:53
> I did not realize it is hardcoded to 8 in iproute2. Because kernel has
> a hard coded limit of
> 2.
> I think we need to fix it in a few places:
> a) we should move the kernel #define to a uapi header file which
> iproute2 can use
> b) there has been a general ask to bump the kernel MAX_LABELS from 2
> and I don't see
> a problem with it yet. so, we could bump it to 8.
>
> Were you planning to post patches for one or both of the above ?.
>
> I can post them too. Let me know.
I would be happy if you could post them both as I very new to the kernel
development and I'm not entirely sure how to do it in the right way.

Kindly

Magnus
>
> Thanks,
> Roopa
>
>
>
>
