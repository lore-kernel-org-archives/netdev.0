From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 10 Jul 2006 23:38:24 +0200
Message-ID: <200607102338.24955.mb@bu3sch.de>
References: <20060710212900.GF13775@tuxdriver.com> <20060710213101.GG13775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57021
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965029AbWGJVgm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 17:36:42 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <20060710213101.GG13775@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 July 2006 23:31, you wrote:
> These patches are to be queued for 2.6.19...
> 
> ---
> 
> The following changes since commit b312d799b324e895745ffe148def234fc60d5b74:
>   Daniel Drake:
>         zd1211rw: usb_clear_halt not allowed in IRQ context
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake:
>       zd1211rw: Add Sagem device ID's
> 
> Larry Finger:
>       bcm43xx: improved statistics

Larry, I see that several patches from you got merged now.
Please make sure that you also submit patches for bcm43xx-d80211.
If you don't, your changes will all be lost, as soon as bcm43xx-d80211
is merged upstream and softmac is dropped.

-- 
Greetings Michael.
