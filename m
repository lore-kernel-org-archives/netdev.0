From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 doesn't work
Date: Tue, 3 Apr 2007 23:56:51 +0200
Message-ID: <20070403215651.GB12963@electric-eye.fr.zoreil.com>
References: <87ircdtbkn.fsf@duaron.myhome.or.jp> <20070403212836.GA12963@electric-eye.fr.zoreil.com> <87ejn13zl7.fsf@duaron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60859 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945997AbXDCWAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 18:00:34 -0400
Content-Disposition: inline
In-Reply-To: <87ejn13zl7.fsf@duaron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> IIRC, First broken one was 9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2.
> To make sure, I'll confirm tomorrow.

If your kernel includes 9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2 but misses
81f4e6c190a0fa016fd7eecaf76a5f95d121afc2, you can consider it a known
behavior.

[...]
> Oh, thanks. I'll try.

Excellent.

-- 
Ueimor
