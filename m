From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16268] New: kernel oops when rmmod the
 tcp_diag modules
Date: Tue, 22 Jun 2010 15:25:18 -0700
Message-ID: <20100622152518.6d701aed.akpm@linux-foundation.org>
References: <bug-16268-10286@https.bugzilla.kernel.org/>
	<20100622141232.4b8f1d4a.akpm@linux-foundation.org>
	<1277244162.2591.198.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lyw@cn.fujitsu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49140 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752711Ab0FVW0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 18:26:01 -0400
In-Reply-To: <1277244162.2591.198.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jun 2010 00:02:42 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> ss is kind of "netstat" with advanced features.

Someone call the namespace police!

> Well, they are faster and more predictable ways to reboot a machine, if
> you ask me :)
> 
> man rmmod
> 
>        -f --force

doh, I missed that.  Yes, that was a bit self-inflicted.

