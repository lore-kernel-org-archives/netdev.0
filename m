From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: TUN device performance regression
Date: Mon, 21 Apr 2014 16:00:59 +0200
Message-ID: <20140421140059.GA3222@torres.zugschlus.de>
References: <1397475118.11864.5.camel@interceptor.in.smoula.net>
 <1397475759.12568.0.camel@interceptor.in.smoula.net>
 <534BF402.6010505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Martin Filip <nexus+kernel@smoula.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:45458 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaDUO1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 10:27:23 -0400
Content-Disposition: inline
In-Reply-To: <534BF402.6010505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2014 at 10:43:14AM -0400, Vlad Yasevich wrote:
> Could you please try this patch.

I was recently bitten by this issue as well and I can confirm that
this patch fixes the issue for me as well in 3.14.1.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
