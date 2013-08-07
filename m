From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: core: fix wrong linkage for ptype_base
 and ptype_all symbols
Date: Tue, 6 Aug 2013 22:00:39 -0600
Message-ID: <20130807040039.GB2274@mail.gmail.com>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
 <1375774371-831-3-git-send-email-sakiwit@gmail.com>
 <5200B01B.9080705@redhat.com>
 <20130806204508.GA2274@mail.gmail.com>
 <1375823201.4004.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35308 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab3HGECu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 00:02:50 -0400
Received: by mail-ob0-f178.google.com with SMTP id ef5so2739877obb.23
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 21:02:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1375823201.4004.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Aug 2013 14:06:41 -0700
>
> On Tue, 2013-08-06 at 14:45 -0600, Jean Sacren wrote:
> 
> > I'm sorry to tell you but the patch is correct. Both symbols of
> > ptype_{base,all} were wrongly declared as extern in net-procfs.c in the
> > first place.
> 
> You are mistaken.

Sorry for the big mistake.

-- 
Jean Sacren
