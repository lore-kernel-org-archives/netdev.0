From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Problems in tc-ematch.8
Date: Wed, 19 Jun 2013 17:55:44 -0700
Message-ID: <20130619175544.522b0346@nehalam.linuxnetplumber.net>
References: <20130619010257.75ABE4143C@snark.thyrsus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: esr@thyrsus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:49897 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934734Ab3FTAzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 20:55:48 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so5629071pbc.29
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:55:47 -0700 (PDT)
In-Reply-To: <20130619010257.75ABE4143C@snark.thyrsus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Jun 2013 21:02:57 -0400 (EDT)
esr@thyrsus.com wrote:

> This is automatically generated email about markup problems in a man
> page for which you appear to be responsible.  If you are not the right
> person or list, please tell me so I can correct my database.
> 
> See http://catb.org/~esr/doclifter/bugs.html for details on how and
> why these patches were generated.  Feel free to email me with any
> questions.  Note: These patches do not change the modification date of
> any manual page.  You may wish to do that by hand.
> 
> I apologize if this message seems spammy or impersonal. The volume of
> markup bugs I am tracking is over five hundred - there is no real
> alternative to generating bugmail from a database and template.
> 
> --
>                              Eric S. Raymond

Thanks for seeing this as well. But also won't apply.
Like other patch, this was not properly rooted in iproute2 repository.

I think you were looking at the last version, not the current code
in iproute2 git repository.

$ patch < ~/Downloads/Problems-in-tc-ematch.8.patch
patching file tc-ematch.8
Hunk #2 FAILED at 67.
1 out of 2 hunks FAILED -- saving rejects to file tc-ematch.8.rej
