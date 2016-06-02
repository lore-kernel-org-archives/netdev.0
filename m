From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 4/6] fix handling of CFLAGS
Date: Thu, 2 Jun 2016 11:35:19 +0900
Message-ID: <574F9B67.6040603@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-4-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33503 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbcFBCfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 22:35:23 -0400
Received: by mail-pa0-f46.google.com with SMTP id um11so1727895pab.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 19:35:23 -0700 (PDT)
In-Reply-To: <1464752905-10347-4-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Frysinger wrote:
> This defaults CFLAGS to -O3 without clobbering settings people have set
> up in the environment already.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Fixed in different way. Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
