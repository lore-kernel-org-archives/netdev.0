From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 10:52:11 -0800
Message-ID: <1356115931.21834.7745.camel@edumazet-glaptop>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	 <1356114663.21834.7697.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:65411 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab2LUSwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:52:19 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so2998284pad.31
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 10:52:18 -0800 (PST)
In-Reply-To: <1356114663.21834.7697.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 10:31 -0800, Eric Dumazet wrote:

> I believe RFC 5961 was implemented in recent linux versions.
> 
> Is the described vulnerability still present ?
> 

By the way, I believe Chrome browser uses private network namespaces,
and statistics are per network namespace, so it should be safe.
