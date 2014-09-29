From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next] r8169: add support for Byte Queue Limits
Date: Mon, 29 Sep 2014 23:11:58 +0200
Message-ID: <20140929211158.GA11633@breakpoint.cc>
References: <1412024209-25468-1-git-send-email-fw@strlen.de>
 <CA+mtBx95KFr=3h_TZWBeM6e7EF4sKAmjRpz5vLxGwi8xC+qQuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60934 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbaI2VMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:12:00 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx95KFr=3h_TZWBeM6e7EF4sKAmjRpz5vLxGwi8xC+qQuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> wrote:
> Thanks for doing this! Can you add a little description in commit log
> on test results, something that would indicate accounting is correct.

Do you have any specific test in mind?

I ran 'super_netperf 40' for 20 minutes without stalls/hangups and
bql monitor seemed to look ok.

Anything else I should use/test with?

Thanks,
Florian
