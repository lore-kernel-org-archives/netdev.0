From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/5] fixed_phy: get_phy_device() doesn't return NULL
 anymore
Date: Mon, 25 Apr 2016 12:46:29 -0700
Message-ID: <571E7415.7000409@gmail.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <7242612.WszImdz4eS@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35674 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933450AbcDYTsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:48:45 -0400
Received: by mail-pf0-f181.google.com with SMTP id n1so72728544pfn.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 12:48:45 -0700 (PDT)
In-Reply-To: <7242612.WszImdz4eS@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/16 10:29, Sergei Shtylyov wrote:
> Now that get_phy_device() no longer returns NULL on error, we don't need
> to check for it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
