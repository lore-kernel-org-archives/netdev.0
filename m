From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Thu, 11 Jul 2013 06:51:46 -0700
Message-ID: <1373550706.4600.38.camel@edumazet-glaptop>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
	 <1373503334.4600.27.camel@edumazet-glaptop>
	 <CALnjE+rA4kPiwemZ+A0GfSMw8OsS=ssRw0S_1i75jyF2HB2D0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	joseph.gasparakis@intel.com, jesse@nicira.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33187 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042Ab3GKNvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 09:51:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id rl6so7942032pac.1
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 06:51:49 -0700 (PDT)
In-Reply-To: <CALnjE+rA4kPiwemZ+A0GfSMw8OsS=ssRw0S_1i75jyF2HB2D0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-11 at 00:45 -0700, Pravin Shelar wrote:

> Nice speculation ;)

Indeed ;) Sorry Pravin !

> 
> I did some digging and found following commit causing problem with GRE
> TSO on bnx setup.

Thanks for taking care of this problem.
