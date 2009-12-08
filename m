From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH-v2 0/3] TI EMAC driver : Make driver re-usable on non-davinci platforms.
Date: Mon, 07 Dec 2009 16:54:24 -0800
Message-ID: <87pr6q475r.fsf@deeprootsystems.com>
References: <1258626507-5570-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davinci-linux-open-source@linux.davincidsp.com,
	netdev@vger.kernel.org
To: Sriramakrishnan <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:60447 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965328AbZLHAyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 19:54:20 -0500
Received: by yxe17 with SMTP id 17so4481248yxe.33
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 16:54:27 -0800 (PST)
In-Reply-To: <1258626507-5570-1-git-send-email-srk@ti.com> (Sriramakrishnan's message of "Thu\, 19 Nov 2009 15\:58\:24 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sriramakrishnan <srk@ti.com> writes:

> The Davinci EMAC peripheral is also available on other TI platforms -
> notably TI AM3517 SoC. The following series of patches modify the driver 
> suitably to make it platform agnostic.
>
> This patch has been generated against the tip of linux-davinci git.

Thanks, applying to davinci git.  Will queue in davinci-next for 2.6.34.

Kevin
