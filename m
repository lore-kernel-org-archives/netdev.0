From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: First set of manpage markup fixes
Date: Mon, 24 Jun 2013 17:02:54 -0700
Message-ID: <20130624170254.15fb1631@nehalam.linuxnetplumber.net>
References: <20130621195721.GA10029@thyrsus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: esr@thyrsus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:47349 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab3FYAC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 20:02:58 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so11741951pbc.1
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 17:02:57 -0700 (PDT)
In-Reply-To: <20130621195721.GA10029@thyrsus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Jun 2013 15:57:21 -0400
"Eric S. Raymond" <esr@thyrsus.com> wrote:

> Enclosed patch fixes inappropriate uses of the .SS macro.  Fuller explanation
> in the change comment.
> 
> There are other problems in these pages that block lifting to
> XML-DocBook, most notably in the command synopses.  They will take
> some creativity to fix.  I'm working on it

Applied
