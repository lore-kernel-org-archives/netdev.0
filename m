From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: r8169 doesn't work
Date: Thu, 05 Apr 2007 04:35:18 +0900
Message-ID: <87abxo53wp.fsf@duaron.myhome.or.jp>
References: <87ircdtbkn.fsf@duaron.myhome.or.jp>
	<20070403212836.GA12963@electric-eye.fr.zoreil.com>
	<87ejn13zl7.fsf@duaron.myhome.or.jp>
	<20070403215651.GB12963@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.jp ([210.171.160.80]:3744 "EHLO parknet.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992549AbXDDTf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 15:35:28 -0400
Received: from ibmpc.myhome.or.jp ([210.171.168.39]:4500)
	by parknet.jp with [XMail 1.21 ESMTP Server]
	id <S11DA8> for <netdev@vger.kernel.org> from <hirofumi@mail.parknet.co.jp>;
	Thu, 5 Apr 2007 04:35:59 +0900
In-Reply-To: <20070403215651.GB12963@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Tue\, 3 Apr 2007 23\:56\:51 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> [...]
>> Oh, thanks. I'll try.
>
> Excellent.

That patchset works fine for me. (i386 + smp, i386 + up, x86_64 + smp)
I hope to include those patches to 2.6.21.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
