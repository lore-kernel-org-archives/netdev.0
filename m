From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull upstream-fixes branch of wireless-2.6
Date: Thu, 20 Apr 2006 08:53:43 -0400
Message-ID: <20060420125336.GA23062@tuxdriver.com>
References: <20060420011232.GA9268@tuxdriver.com> <200604201051.03881.mb@bu3sch.de> <20060420015752.01d36087.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, jeff@garzik.org,
	netdev@vger.kernel.org, torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:43789 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750878AbWDTMyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 08:54:06 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060420015752.01d36087.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 01:57:52AM -0700, Andrew Morton wrote:

> And I really need to find a way of getting git-wireless into -mm.  Problem
> is, it's based off git-netdev-all and when John's tree is synced to a later
> version of Linus's tree than Jeff's tree, all hell breaks loose at my end. 

FWIW, I think this issue should be gone (hopefully never to return).
For a while I was pulling from Jeff's netdev tree as a way to fix-up
a git administration error I had inflicted upon myself...  That need
has disappeared since 2.6.17 opened and Jeff pushed his upstream
branch to Linus.

At present, all the branches in wireless-2.6 only pull from linux-2.6.
I am still pushing (i.e. requesting Jeff's pull) to netdev-2.6,
if that matters.

Maybe the current wireless-2.6 tree fits into your system better?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
