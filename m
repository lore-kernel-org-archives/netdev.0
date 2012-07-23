From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] rtnl: do not include num_rx_queues into msg
 when CONFIG_RPS is not set
Date: Mon, 23 Jul 2012 13:03:49 +0200
Message-ID: <20120723110349.GA1669@minipsycho.orion>
References: <1342942002-26731-1-git-send-email-jiri@resnulli.us>
 <20120722.122746.1524911782331447848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45726 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab2GWLDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 07:03:54 -0400
Received: by bkwj10 with SMTP id j10so5081099bkw.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 04:03:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120722.122746.1524911782331447848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 22, 2012 at 09:27:46PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sun, 22 Jul 2012 09:26:42 +0200
>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Jiri, I've been patiently waiting for you to ACK Mark A. Greear's
>patch fixing this bug, did you not see it at all?

Oh I missed that. That email somehow skipped my inbox and went only to
ml folder...

>
>http://patchwork.ozlabs.org/patch/172393/
>
>I'm just going to apply it since you're not watching for fixes
>for code you've changed.
