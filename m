From: kuznet@ms2.inr.ac.ru
Subject: Re: fix TCP roundtrip time update code
Date: Wed, 4 Jun 2003 04:43:22 +0400 (MSD)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200306040043.EAA24505@dub.inr.ac.ru>
References: <Mutt.LNX.4.44.0306041021450.28035-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, gandalf@wlug.westbo.se,
	linux-kernel@vger.kernel.org, linux-ia64@linuxia64.org,
	netdev@oss.sgi.com, davem@redhat.com, akpm@digeo.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: jmorris@intercode.com.au (James Morris)
In-Reply-To: <Mutt.LNX.4.44.0306041021450.28035-100000@excalibur.intercode.com.au> from "James Morris" at Jun 04, 2003 10:24:14 AM
List-Id: netdev.vger.kernel.org

Hello!

> This might be the solution to one of the 'must-fix' bugs for the
> networking, which nobody so far was quite able to track down.

No doubts. All the symptoms are explained by this. I hope Andrew
will confirm that the problem has gone.

Alexey
