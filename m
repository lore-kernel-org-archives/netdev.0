From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] irda: ep7211-sir: Convert to platform_diver
Date: Sat, 1 Dec 2012 20:50:22 +0000
Message-ID: <201212012050.22382.arnd@arndb.de>
References: <1354360046-4818-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58879 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab2LAUuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 15:50:51 -0500
In-Reply-To: <1354360046-4818-1-git-send-email-shc_work@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 01 December 2012, Alexander Shiyan wrote:
> This patch converts ep7211-sir driver to platform_driver.
> Since driver can be used not only for EP7211 CPU, function names
> was be renamed to generic clps711x...
> 
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>

Acked-by: Arnd Bergmann <arnd@arndb.de>
