From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 5/5] bcm43xx-d80211: fix sending of fragments
Date: Thu, 15 Jun 2006 18:55:11 +0200
Message-ID: <200606151855.11953.mb@bu3sch.de>
References: <20060612191606.7AA8E48391@silver.suse.cz> <200606122135.17198.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57044
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751447AbWFOQzy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 12:55:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <200606122135.17198.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 June 2006 21:35, Michael Buesch wrote:
> On Monday 12 June 2006 21:16, Jiri Benc wrote:
> > This makes fragmentation work with bcm43xx.
> > 
> > Signed-off-by: Jiri Benc <jbenc@suse.cz>
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> The other patch will get my sign-off tomorrow (I think modified, though).
> I don't have time to look at it more close, now.

Please also merge the other patch. It is too hard to figure out
the dependencies for me now. So simply merge it and I will submit
a fixup patch later, after you pushed it out.
The Subject was:
[incomplete 2/5] bcm43xx-d80211: per-queue TX flow control

It's not so much of trouble, if we break wireless-dev for one or
two days, so this is easiest.
Please notify me after you pushed the stuff to public repository,
so I can pull and fix it.

-- 
Greetings Michael.
