From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] 6lowpan: Remove unused pointer in lowpan_header_create()
Date: Mon, 10 Feb 2014 18:40:58 +0100
Message-ID: <20140210174056.GB12594@omega>
References: <20140207225838.18ad2ffb@spike>
 <20140209.183829.1382019488417715676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: cengelma@gmx.at, netdev@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	jukka.rissanen@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:58838 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbaBJRlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 12:41:02 -0500
Received: by mail-ea0-f181.google.com with SMTP id k10so948527eaj.12
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 09:41:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140209.183829.1382019488417715676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I need the hdr pointer for my upcomming patches. Nevertheless it
should be removed... it's not used anymore.

I am wondering why this patch was accepted, it's not a bug fix. Is
net-next open again?

- Alex
