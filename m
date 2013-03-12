From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Tue, 12 Mar 2013 09:56:16 -0600
Message-ID: <513F5020.7090408@genband.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com> <1362888229.4051.2.camel@edumazet-glaptop> <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com> <1362891937.4051.25.camel@edumazet-glaptop> <20130310004904.de508bfa.billfink@mindspring.com> <1362894876.4051.27.camel@edumazet-glaptop> <513F3BE1.2080409@genband.com> <20130312154245.GA13101@casper.infradead.org> <513F4F87.5040308@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Bill Fink <billfink@mindspring.com>, Vimal <j.vimal@gmail.com>,
	netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:33064 "EHLO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101Ab3CLP5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:57:32 -0400
In-Reply-To: <513F4F87.5040308@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2013 09:53 AM, Chris Friesen wrote:

> I have strong opinions either way, but I don't think "imprecision" is a
> problem in practice.

Oops, make that "I don't have strong opinions...".   :)
