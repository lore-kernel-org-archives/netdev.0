From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 2/6] doc: fix parallel build of html/man pages
Date: Thu, 2 Jun 2016 11:39:46 +0900
Message-ID: <574F9C72.7010305@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-2-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33261 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbcFBCju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 22:39:50 -0400
Received: by mail-pf0-f175.google.com with SMTP id b124so25179396pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 19:39:49 -0700 (PDT)
In-Reply-To: <1464752905-10347-2-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> The use of the same tempdir prevents building of these files in parallel.
> So build all of them in unique tempdirs so we can do them in parallel.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.  Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
