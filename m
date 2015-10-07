From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Fix unused variable compile warning
Date: Tue, 6 Oct 2015 20:19:33 -0600
Message-ID: <56148135.80804@cumulusnetworks.com>
References: <1443714544-21595-1-git-send-email-dsa@cumulusnetworks.com>
 <CAHA+R7PTyS=wtowhKZ4osDs_VF=UJvfhw_xkWO3PQZuiFdnTsw@mail.gmail.com>
 <20151005.233537.1854084467334631982.davem@davemloft.net>
 <20151007010237.GD21067@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, dsa@cumulusnetworks.com,
	netdev@vger.kernel.org, dsahern@gmail.com
To: Simon Horman <horms@verge.net.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35757 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbbJGCTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 22:19:35 -0400
Received: by pacfv12 with SMTP id fv12so5118943pac.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 19:19:35 -0700 (PDT)
In-Reply-To: <20151007010237.GD21067@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/15 7:02 PM, Simon Horman wrote:
> lvs-devel would be better yet.
> I submitted an identical patch there yesterday.
>
> I'll pick up David's version and send it to Pablo ASAP.

Thanks, Simon. I need to remember to consult the MAINTAINERS file.
