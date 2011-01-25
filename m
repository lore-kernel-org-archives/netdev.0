From: Stanislav Fomichev <kernel@fomichev.me>
Subject: Re: [PATCH] netconsole: kbuild dependency fix
Date: Tue, 25 Jan 2011 23:40:33 +0300
Message-ID: <4d3f3547.875bdf0a.320e.4d37@mx.google.com>
References: <4d3c86b8.114ddf0a.7de4.ffffe043@mx.google.com>
 <20110124.233705.260069637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56776 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab1AYUkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 15:40:41 -0500
Received: by fxm20 with SMTP id 20so220444fxm.19
        for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 12:40:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110124.233705.260069637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please show the configuration and build error messages from when the
> build fails, otherwise we have to guess what causes the dependency.
Hm, I can't reproduce it (the config which caused the error was not saved).
And honestly, looking deeper into the code I can't imagine how could I get
an error here.
So sorry for confusing you.
