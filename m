From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.20-git14 rtl8139 possible circular locking dependency detected
Date: Sun, 18 Feb 2007 00:06:46 +0100
Message-ID: <6bffcb0e0702171506u68c26be0u3c8fabeb21c125ee@mail.gmail.com>
References: <45D7569F.9030502@googlemail.com>
	 <20070217221252.GA16954@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:36141 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964863AbXBQXGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 18:06:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so407393uga
        for <netdev@vger.kernel.org>; Sat, 17 Feb 2007 15:06:51 -0800 (PST)
In-Reply-To: <20070217221252.GA16954@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/02/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Michal Piotrowski <michal.k.k.piotrowski@gmail.com> :
> [...]
>
> Did you enable RTL8139_DEBUG ?
>
> If so you can try the patch below.
>

I enabled debugging
#define RTL8139_DEBUG 3

Here is a full log
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.20-git14/bug.txt
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.20-git14/git-config

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)
