From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PATCH_ppp_mp_explode_redesign
Date: Tue, 7 Apr 2009 09:43:26 +0000
Message-ID: <20090407094325.GA6031@ff.dom.local>
References: <1239052276.28824.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paoloni, Gabriele" <gabriele.paoloni@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulus@samba.org" <paulus@samba.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:19900 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbZDGJng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 05:43:36 -0400
Received: by wa-out-1112.google.com with SMTP id j5so2022397wah.21
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 02:43:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1239052276.28824.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06-04-2009 23:11, Dan Williams wrote:
> On Mon, 2009-04-06 at 17:38 +0100, Paoloni, Gabriele wrote:
>> Hi 
>>
>> Can anybody tell me what is the procedure that is followed to apply the patch and when it will be officially released.
> 
> Dave Miller (networking maintainer) applied your patch to his various
> trees on March 13th.  Since 2.6.29 was in bug-fix only mode at that
> time, your patch was too late to be included 2.6.29.  It has just been
> merged into Linus' linux-2.6 tree [1] (which will become 2.6.30) via
> Dave Miller's tree.  So it appears your patch will be included in the
> 2.6.30 kernel when that is released.
> 
> If you think your patch is regression-free and appropriate for stable
> kernels (2.6.27, 2.6.28, etc) you might try to send it to the stable
> team for inclusion in subsequent stable kernel updates.

I guess it's preferred here to ask David for sending to -stable yet
(and it usually needs merging to the net-2.6 tree first).

Jarek P.
