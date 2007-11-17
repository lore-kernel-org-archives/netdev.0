From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: SFQ: backport some features from ESFQ (try 5)
Date: Sat, 17 Nov 2007 07:34:39 +0200
Message-ID: <20071117053343.M46543@visp.net.lb>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org> <473D0779.5050900@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: Corey Hickey <bugfood-ml@fatooh.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:57868 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbXKQFez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 00:34:55 -0500
In-Reply-To: <473D0779.5050900@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 18:59:05 -0800, Corey Hickey wrote
> Corey Hickey wrote:
> > Patchset try 2 addresses the review by Michael Buesch.
> > Patchset try 3 addresses the review by Patrick McHardy.
> > Patchset try 4 has a few cosmetic improvements.
> > Patchset try 5 addresses further review by Patrick McHardy.
> > 
> > This set of patches is substantially the same as my previous try, with
> > changes made according to Patrick's recommendations.
> 
> Any comments? Patrick? I know you're busy, but you've been sending
> reviews for my patches so far and yet another one would be much appreciated.
> 
> Thanks,
> Corey
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
For me also it is very interesting to have SFQ with this patches, cause right 
now SFQ suitable only for low-bandwidth customers. With this patch i can use 
it much more, and QOS will become much more flexible for me.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

