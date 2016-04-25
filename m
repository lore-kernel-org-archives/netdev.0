From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/5] xgene: get_phy_device() doesn't return NULL anymore
Date: Mon, 25 Apr 2016 12:46:13 -0700
Message-ID: <571E7405.90009@gmail.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <73083313.ix2iJdrut5@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	isubramanian@apm.com, kchudgar@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32907 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933450AbcDYTsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:48:30 -0400
Received: by mail-pf0-f178.google.com with SMTP id 206so21457764pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 12:48:30 -0700 (PDT)
In-Reply-To: <73083313.ix2iJdrut5@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/16 10:27, Sergei Shtylyov wrote:
> Now that get_phy_device() no longer returns NULL on error, we don't need
> to check for it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
