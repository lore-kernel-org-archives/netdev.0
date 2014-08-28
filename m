From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ip netns: Show error message if mkdir failed to create
 /var/run/netns
Date: Thu, 28 Aug 2014 15:54:18 +0200
Message-ID: <53FF348A.60701@6wind.com>
References: <1409230964-6182-1-git-send-email-vadim4j@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: vadimk <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:56000 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaH1NyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 09:54:23 -0400
Received: by mail-we0-f180.google.com with SMTP id w61so805182wes.11
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 06:54:21 -0700 (PDT)
In-Reply-To: <1409230964-6182-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/08/2014 15:02, vadimk a =C3=A9crit :
> Currently if mkdir failed with "Permission denied" error then "mount =
--make-shared ..."
> error message will be showed because /var/run/netns does not exist.
> ---
Your 'Signed-off-by' is missing.
