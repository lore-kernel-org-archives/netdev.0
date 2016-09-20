From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 11:42:31 -0700
Message-ID: <1474396951.23058.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920133915.GJ1843@nanopsycho.orion>
         <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474381092.23058.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920174649.GN1843@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33998 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbcITSmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 14:42:33 -0400
Received: by mail-pf0-f170.google.com with SMTP id p64so10072215pfb.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 11:42:33 -0700 (PDT)
In-Reply-To: <20160920174649.GN1843@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 19:46 +0200, Jiri Pirko wrote:

> 
> This patch makes ubsan silent.

Thanks Jiri, I will post an official patch then ;)
