From: Vadim Kochan <vadim4j@gmail.com>
Subject: RE: [iproute2,v4] tc: add support for vlan tc action
Date: Fri, 21 Nov 2014 13:10:04 +0200
Message-ID: <CAMw6YJK0_TLrqcUTkrE9rX_rbgJQ5-3O5D7ToBZvbPCNyaK3yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:48964 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbaKULKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 06:10:12 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so11630017wiv.12
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 03:10:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> + fprintf(stderr, "unexpexted \"%s\" - action already specified\n",
> + *argv);


Seems like typo in "unexpexted" ?

Regards,
Vadim Kochan
