From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Fri, 24 May 2013 06:47:35 -0700
Message-ID: <1369403255.3301.398.camel@edumazet-glaptop>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>
	  <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>
	   <1369222666.3301.304.camel@edumazet-glaptop>
	 <519CB0D3.8000406@rcs-rds.ro>  <1369230739.3301.334.camel@edumazet-glaptop>
	 <519CE6F0.3040703@rcs-rds.ro>  <519DD7A4.9090801@rcs-rds.ro>
	 <1369324409.3301.382.camel@edumazet-glaptop>
	 <1369329033.3301.389.camel@edumazet-glaptop> <519F3572.7060503@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Petre <daniel.petre@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:51712 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab3EXNri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 09:47:38 -0400
Received: by mail-pa0-f44.google.com with SMTP id wp1so1714814pac.3
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 06:47:37 -0700 (PDT)
In-Reply-To: <519F3572.7060503@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 12:40 +0300, Daniel Petre wrote:
> On 05/23/2013 08:10 PM, Eric Dumazet wrote:

> 
> we have compiled it, tested it few times and.. nothing evil happens anymore!

Thanks for the report. I'll cook the various variants of the patch.
