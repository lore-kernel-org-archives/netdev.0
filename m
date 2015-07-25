From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ravb: minimize TX data copying
Date: Sat, 25 Jul 2015 22:40:37 +0200
Message-ID: <20150725204037.GA2172@nanopsycho.fritz.box>
References: <7692456.7SI5hJLWyQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34271 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964824AbbGYUkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 16:40:41 -0400
Received: by wibud3 with SMTP id ud3so97846927wib.1
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2015 13:40:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <7692456.7SI5hJLWyQ@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 25, 2015 at 09:20:30PM CEST, sergei.shtylyov@cogentembedded.com wrote:

<snip>

>The patch is against Dave Miller's 'net-next.git' repo.

You can just put "net-next" into patch brackets like:
[patch net-next] whatever
That would do the trick :)
