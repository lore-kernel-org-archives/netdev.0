From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH 2/6] zd1211rw: Pass more management frame types up to host
Date: Thu, 3 Aug 2006 08:09:06 +0200
Message-ID: <20060803060905.GA1622@p15091797.pureserver.info>
References: <1154468615618-git-send-email-kune@deine-taler.de> <1154468615613-git-send-email-kune@deine-taler.de> <20060802215828.GB5084@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:62946 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S932369AbWHCGJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 02:09:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060802215828.GB5084@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-02 17:58 John W. Linville wrote:

> On Tue, Aug 01, 2006 at 11:43:31PM +0200, Ulrich Kunitz wrote:
> > From: Daniel Drake <dsd@gentoo.org>
> > 
> > We'll be needing these at some point...
> 
> This one doesn't really seem like a fix.  But since the later fixes
> seem to depend on it, I guess it makes sense to take it.
> 
> I just didn't want you to think I wasn't looking... :-)

John,

you are absolutely right. The patch is needed, because the patch
sequence would break without it.

Would it be acceptable if I hint on such "bridge" patches in the
futture or should we create a clean patch sequence? The latter would
require us to rewrite patches manually.

BTW we will have a greater number of patches for 2.6.19 (around 30),
which supports more devices and also cleans stuff. Some work is
however still required.

Regards,

Uli

-- 
Uli Kunitz
