From: Roland Dreier <rdreier@cisco.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Thu, 12 Apr 2007 16:18:24 -0700
Message-ID: <adaodltdvwf.fsf@cisco.com>
References: <20070402014319.GA8345@zip.com.au>
	<20070402001300.3b66007d.akpm@linux-foundation.org>
	<20070412225249.GU8345@zip.com.au>
	<20070412161305.09cb28b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: CaT <cat@zip.com.au>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753400AbXDLXSq@vger.kernel.org>
In-Reply-To: <20070412161305.09cb28b8.akpm@linux-foundation.org> (Andrew Morton's message of "Thu, 12 Apr 2007 16:13:05 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Apr 11 22:14:02 '  eth0:220898233988841368 66750274    0    0    0     0          0  86458738 52386430545 101089219 199313    0    0     0  199313          0 '

 > > Apr 11 22:15:02 '  eth0:17227454818 81381144    0    0    0     0          0         0 33091307388 86658381    0    0    0     0       0          0 '

 > But in fact I think you're saying that the numbers go bad, and then stay bad.

Doesn't look like it -- one minute after the first hiccup the eth0 #s
look reasonable again.

 - R.
