From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [GIT PULL 0/5] IEEE 802.15.4 last-minute fixes.
Date: Tue, 4 Aug 2009 12:51:48 +0400
Message-ID: <20090804085147.GA6724@doriath.ww600.siemens.net>
References: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
 <20090803.193546.102476162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:54404 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773AbZHDIwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 04:52:12 -0400
Received: by ewy10 with SMTP id 10so148355ewy.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 01:52:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090803.193546.102476162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2009 at 07:35:46PM -0700, David Miller wrote:
> From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Date: Tue,  4 Aug 2009 02:51:37 +0400
> 
> > Please pull several minor fixes for the IEEE 802.15.4 stack.
> 
> No.
> 
> Removing an unused macro IS NOT A BUG FIX!
> 
> Marking a variable 'const' IS NOT A BUG FIX!
> 
> And therefore it is absolutely, positively, not appropriate for
> 2.6.31-rcX at this time.
> 
> Do not send any more patches to me until you can sort your
> changes properly.

Will you pull the serie if I'll remove those two patches? Documentation
fix isn't that important, however I'd really ask to pull the remaining
two patches.

-- 
With best wishes
Dmitry

