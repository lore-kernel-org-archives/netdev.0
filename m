From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH] HFSC (7) & (8) documentation + assorted changes
Date: Wed, 26 Oct 2011 11:27:04 +0200
Message-ID: <4EA7D268.1050504@ziu.info>
References: <1319616922-18034-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:24341 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932510Ab1JZJhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 05:37:13 -0400
In-Reply-To: <1319616922-18034-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.10.2011 10:15, Mike Frysinger wrote:
>
> I've read it many times over, but it's a lengthy chunk of text - so try
> to be understanding in case I made some mistakes.
>

TBH, I planned to do some fixes / corrections (minor ones) to the 
version I submitted back then, though I had two doubts after looking at 
it after a bit of time:

- too long / too detailed / hard to read
   (or ITOW, following HFSC paper to closely to be of practical use for
   someone just wanting to know how it works, without [too] gritty
   details)
- some friendlier format with man export (asciidoc ? yodl ?
   reText ? etc. - not sure what's it the policy regarding iproute2)
   as otherwise it will be quite a burden to maintain / update.

If my memory serves right, one of the corner cases described in it might 
have been fixed by a patch I submitted a good few months ago, though 
I'll have to read it to be sure. And there're few other small 
long-overdue patches I'm sitting on (they won't change anything 
algorithmically, but at least one could be noted in the text - though 
that can be changed any time in the future, and if the patches get 
accepted at all of course).

Another thing was minor kernel patch to stab, and the docs assumed it 
was added (not sure if you corrected it).


I'll read this version and see how it differs (and try to recollect what 
I wanted to fix in the past).
