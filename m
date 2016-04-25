From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 5/5] of_mdio: get_phy_device() doesn't return NULL anymore
Date: Mon, 25 Apr 2016 12:47:08 -0700
Message-ID: <571E743C.8010303@gmail.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <2718908.IUaySUkXrd@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33832 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933450AbcDYTtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:49:24 -0400
Received: by mail-pa0-f42.google.com with SMTP id r5so62371443pag.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 12:49:24 -0700 (PDT)
In-Reply-To: <2718908.IUaySUkXrd@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/16 10:31, Sergei Shtylyov wrote:
> Now that get_phy_device() no longer returns NULL on error, we don't need
> to check for it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
