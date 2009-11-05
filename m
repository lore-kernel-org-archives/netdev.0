From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Wed, 04 Nov 2009 23:25:29 -0800 (PST)
Message-ID: <20091104.232529.96055149.davem@davemloft.net>
References: <7916.1257300093@turing-police.cc.vt.edu>
	<4AF1AF28.2030106@codefidence.com>
	<6025.1257388392@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gilad@codefidence.com, ilpo.jarvinen@helsinki.fi,
	eric.dumazet@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ori@comsleep.com
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754436AbZKEHZG@vger.kernel.org>
In-Reply-To: <6025.1257388392@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis.Kletnieks@vt.edu
Date: Wed, 04 Nov 2009 21:33:12 -0500

> On Wed, 04 Nov 2009 18:43:20 +0200, Gilad Ben-Yossef said:
> 
>> OK, I thing I've got it.
>> 
>> Kindly try the next patch. It goes on top (in addition to) the previous 
>> one. This should fix the crash.
> 
> OK. much better.  Have been up for about 25 minutes now, and fetchmail has
> pulled down e-mail several times, and no proboems seen.

Thank you for testing.
