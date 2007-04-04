From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 doesn't work
Date: Wed, 4 Apr 2007 22:21:35 +0200
Message-ID: <20070404202135.GA7809@electric-eye.fr.zoreil.com>
References: <87ircdtbkn.fsf@duaron.myhome.or.jp> <20070403212836.GA12963@electric-eye.fr.zoreil.com> <87ejn13zl7.fsf@duaron.myhome.or.jp> <20070403215651.GB12963@electric-eye.fr.zoreil.com> <87abxo53wp.fsf@duaron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42077 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075AbXDDUYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 16:24:37 -0400
Content-Disposition: inline
In-Reply-To: <87abxo53wp.fsf@duaron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> That patchset works fine for me. (i386 + smp, i386 + up, x86_64 + smp)

Cool.

> I hope to include those patches to 2.6.21.

The patchkit is scheduled for the next merge window. It fixes things for
some users but:
1. it missed the merge window of 2.6.21
2. it is not completely non-intrusive
3. it has been tested in -mm or by users whose driver did not work

-> too late in the release cycle.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
