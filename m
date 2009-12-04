From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v9 2/2] TCPCT part 1i: remove old tcp_optlen()
 function
Date: Fri, 04 Dec 2009 07:06:00 -0500
Message-ID: <4B18FB28.4030707@gmail.com>
References: <4B184A20.4050005@gmail.com>	<4B184FC1.8020805@gmail.com> <20091203.155651.04450554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:54126 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbZLDMGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 07:06:00 -0500
Received: by iwn1 with SMTP id 1so1565386iwn.33
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2009 04:06:06 -0800 (PST)
In-Reply-To: <20091203.155651.04450554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> These changes are probably fine but are too late for the current
> merge window, please resubmit them (with any requested changes made
> by reviewers) for the next merge window.
> 
> Thanks.
> 
OK.  These were split from the main part 1 sequence (looking back, both
by Ilpo's review at different times), because he objected to "cleanup"
patches being included with "new" features.  They've both been in 4 to 6
previous patch variants.

(More review would be good, and I'd be more comfortable with review by
somebody that could actually test this patch.  That's why the CC:
according to Documentation/SubmittingPatches part 13.)

I'm a bit unclear on "merge window", and am unable to find information
in the Documentation tree.  I see that there was a message that came in
the middle of my patch submission:

   Re: README: net-next-2.6 plans...

Trying to understand the process:  When I first started sending patches
in early October against the -2.6 tree, I was told privately to make
them against net-next-2.6 instead.  Does this mean these "cleanup"
patches should be made for -2.6 now?
