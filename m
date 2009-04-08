From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12954] New: SAMEIP --nodst functionality gone
 missing
Date: Wed, 08 Apr 2009 17:32:48 +0200
Message-ID: <49DCC3A0.7050001@trash.net>
References: <bug-12954-10286@http.bugzilla.kernel.org/> <20090407143509.05ab3b28.akpm@linux-foundation.org> <Pine.LNX.4.62.0904080941370.10428@wlug.westbo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berni@birkenwald.de,
	netfilter-devel@vger.kernel.org
To: Martin Josefsson <gandalf@mjufs.se>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.62.0904080941370.10428@wlug.westbo.se>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Resend to mailing list, I didn't notice this had left bugzilla]

Martin Josefsson wrote:
> Patrick, how about making the ipaddress selection based on only client 
> ipaddress behaviour selectable with an SNAT parameter if the problem 
> with the patch is that the distribution can be uneven for a small number 
> of clients?

Actually I think the results back then were incorrect or it was
just bad luck or something. Ideally we would just enable this
unconditionally I think. I'll do some testing of the distribution
myself during the next days and see how it goes.
