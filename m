From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv3 00/24] Add first IPv6 support to IPVS
Date: Wed, 3 Sep 2008 11:03:59 +0200
Message-ID: <f4845fc0809030203hc59de33k15e35ba62a02be07@mail.gmail.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
	 <20080903004050.GA12550@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net,
	vbusam@google.com
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:31032 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbYICJEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 05:04:11 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out3.google.com with ESMTP id m83941ZO015491
	for <netdev@vger.kernel.org>; Wed, 3 Sep 2008 10:04:01 +0100
Received: from fg-out-1718.google.com (fgbl27.prod.google.com [10.86.88.27])
	by zps36.corp.google.com with ESMTP id m8393xcq031839
	for <netdev@vger.kernel.org>; Wed, 3 Sep 2008 02:04:00 -0700
Received: by fg-out-1718.google.com with SMTP id l27so95648fgb.33
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 02:03:59 -0700 (PDT)
In-Reply-To: <20080903004050.GA12550@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2008 at 2:40 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 02, 2008 at 03:55:31PM +0200, Julius Volz wrote:
>> Hi Horms,
>>
>> Here comes the whole batch again! I've fixed almost all style issues
>> reported by checkpatch.pl, except for some little things which look like
>> they could stay like they are for now (down to 3 warnings and 2 errors).
>> I also integrated your other comments and removed the patch that
>> adds the changelog information (not needed anymore, according to
>> Stephen).
>
> Hi Julius,
>
> thanks once again, this series addresses all of the (minor) concerns that
> I had yesterday. I'd like to let them sit on netdev for another day or two,
> to give a chance for further review by others. If things are still
> clear at that time I think it would be a good time to merge things.

Yes, sounds good! Thanks!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
