From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Fri, 18 May 2012 20:16:46 +0200
Message-ID: <201205182016.51489.linux@rainbow-software.org>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1-out2.atlantis.sk ([80.94.52.71]:51161 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753495Ab2ERSYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 14:24:17 -0400
In-Reply-To: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 May 2012 19:39:29 Paul Gortmaker wrote:
> It was amusing that linux was able to make use of this 1980's
> technology on machines long past its intended lifespan, but
> it probably should go now -- it is causing issues in some
> distros[1], and while that might be fixable, it is just not
> worth it.
>
> [1]
> http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-card-
>not-detecting-934344/

That looks like a bug elsewhere and removing this driver will not fix it.

-- 
Ondrej Zary
