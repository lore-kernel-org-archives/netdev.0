From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Update of the r8169 branch
Date: Wed, 20 Sep 2006 23:40:10 +0200
Message-ID: <20060920214010.GA7879@electric-eye.fr.zoreil.com>
References: <20060726215840.GA4032@electric-eye.fr.zoreil.com> <4511A4F0.6050101@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Matt Bockol <mbockol@carleton.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:26285 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932151AbWITVlg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 17:41:36 -0400
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <4511A4F0.6050101@kernelpanic.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(adding netdev to Cc: so that the patch gets publically known)

Boris B. Zhmurov <bb@kernelpanic.ru> :
[...]
> Hello Francois. I've figured out, that this patch wasn't merged in 
> linux-2.6.18 :(

Bad timing. Patches are available.

> Is there any plans to merge it in mainline ?

Jeff pulled most of the r8169 branch. I can't answer for him but
I guess that the answer is RSN.

> And is there any patches available against linux-2.6.18 release?

The content of the r8169 branch in the git repository can be retrieved at:

http://www.fr.zoreil.com/people/francois/misc/20060920-2.6.18-r8169-test.patch

It should support 8167 as is.

-- 
Ueimor
