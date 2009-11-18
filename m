From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 17/11]Optimize the upload speed for PPP connection.
Date: Tue, 17 Nov 2009 23:00:55 -0500
Message-ID: <4B037177.7060501@gmail.com>
References: <faf197be196ee.196eefaf197be@huawei.com> <20091117.012248.86306050.davem@davemloft.net>            <4B0278D9.6030806@gmail.com> <13129.1258483787@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: huananhu@huawei.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:35987 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908AbZKREAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 23:00:54 -0500
In-Reply-To: <13129.1258483787@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valdis.Kletnieks@vt.edu wrote:
> The '-- ' *convention* isn't even at the next layer up, MIME.  If anything,
> it's out at the liveware level (though some MUAs provide code to make it
> a bit easier to deal with...)
> 
Hey Valdis, nice to hear from you....


> (Feel free to cite RFC chapter-and-verse if you disagree, and note that
> 'Informational' RFCs are never standards. ;)
> 
Yeah, a quick check shows it's mentioned in MIME RFC-1341 (June 1992), but
certainly going back to "Proposed standard for message encapsulation"
RFC-934 (January 1985) at the very least.  I seem to remember that Marshall
or Stef or somebody used it for digest sections too, but don't remember the
RFC number or a good search term.

Still, (relevance here) a convention observed for patches.
