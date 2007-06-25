From: "pradeep singh" <pradeep.rautela@gmail.com>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing, take 2
Date: Mon, 25 Jun 2007 11:16:55 +0530
Message-ID: <a901b49a0706242246w11865c1bq7cc8eebeb278f5cd@mail.gmail.com>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
	 <a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
	 <20070623095446.c1a9c697.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:40964 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbXFYFq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 01:46:56 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1685648wah
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 22:46:56 -0700 (PDT)
In-Reply-To: <20070623095446.c1a9c697.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/23/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 21 Jun 2007 18:48:30 +0530 "pradeep singh" <pradeep.rautela@gmail.com> wrote:
> > Hi,
> > My mistake.
> > Resending after reformatting the patch by hand.
> > Looks like gmail messes the plain text patches.
> >
>
> That's still mangled so I typed it in again.
Sorry Andrew.
>
> Please always include a full changlog with each version of a patch.
point noted down.
>
> I do not know what this patch does - please provide a changelog.  In this
> case it should tell us whether and how this null pointer deref is actually
> occuring and if so, why.
affirmative.
>
> As well as a full description of the problem which it solves, a changelog
> should also describe _how_ it solved it, but that is sufficiently obvious
> in this case.

Thanks for the invaluable suggestion Andrew.

Thanks a lot once again.

~pradeep
>
>
> Thanks.
>


-- 
Pradeep
