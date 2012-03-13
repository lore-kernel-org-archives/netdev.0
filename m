From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Mon, 12 Mar 2012 22:13:14 -0700
Message-ID: <CAHo-OowqCV8MG=_-4hZ+rXuXHUvnDF_uP07upf62V_GjVjM4pg@mail.gmail.com>
References: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35448 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab2CMFNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 01:13:15 -0400
Received: by yenl12 with SMTP id l12so151690yen.19
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 22:13:15 -0700 (PDT)
In-Reply-To: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not really sure about this one, this might be more of a discussion starter...
