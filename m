From: "Julius Volz" <juliusv@google.com>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Fri, 15 Aug 2008 13:31:59 +0200
Message-ID: <f4845fc0808150431l778618dcjf848774c38d86470@mail.gmail.com>
References: <20080815001250.GC15825@verge.net.au>
	 <20080814.172508.15803616.davem@davemloft.net>
	 <20080815010235.GD15825@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, sven.wegener@stealer.net,
	wensong@linux-vs.org, ja@ssi.bg
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:7621 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbYHOLcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 07:32:10 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out3.google.com with ESMTP id m7FBW1HL019782
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 12:32:01 +0100
Received: from ug-out-1314.google.com (ugcx30.prod.google.com [10.66.125.30])
	by wpaz13.hot.corp.google.com with ESMTP id m7FBW0ie018846
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 04:32:00 -0700
Received: by ug-out-1314.google.com with SMTP id x30so291490ugc.20
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 04:31:59 -0700 (PDT)
In-Reply-To: <20080815010235.GD15825@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 3:02 AM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Aug 14, 2008 at 05:25:08PM -0700, David Miller wrote:
>> From: Simon Horman <horms@verge.net.au>
>> Date: Fri, 15 Aug 2008 10:12:52 +1000
>>
>> > Julius, Sven and I would particularly like Julius' two changes to go
>> > in. They add a new interface which is currently unused and thus the
>> > likelihood of breakage seems low.
>>
>> Actually these are the two changes that should not go in at this
>> time.  This netlink stuff is a new feature, therefore not appropriate
>> to merge outside of the merge window.
>>
>> Bug fixes only now, please.
>
> Hi Dave,
>
> thanks for the clarification. In that case I believe that
> all of these changes can wait.

Ok, how does the process work? Do I send the patches again at a later
point or will they be pulled from your tree then?

Julius

-- 
Google Switzerland GmbH
