From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 15:00:58 +0200
Message-ID: <AANLkTinDQ-n3Y2_8PtvdWSxkYV8Kvj8on3iEeHsBSFB-@mail.gmail.com>
References: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
	<AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
	<9e62acde19ef75f3f77468cd81ed7ffd@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:41351 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab1AZNA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 08:00:59 -0500
Received: by pxi15 with SMTP id 15so59750pxi.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 05:00:58 -0800 (PST)
In-Reply-To: <9e62acde19ef75f3f77468cd81ed7ffd@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Latest stable, 2.6.37

Please apply this patch [1] and see if it's still happening.

thanks,
Daniel

[1] http://www.spinics.net/lists/netdev/msg152204.html
