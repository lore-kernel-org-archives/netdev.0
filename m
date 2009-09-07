From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 00/12] Gigaset driver patches for 2.6.32
Date: Sun, 06 Sep 2009 18:26:46 -0700
Message-ID: <1252286806.2139.1.camel@desktop>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	Hansjoerg Lipp <hjlipp@web.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758562AbZIGB0m@vger.kernel.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-09-06 at 20:58 +0200, Tilman Schmidt wrote:
> Dave,
> 
> following is a series of patches for the Gigaset driver which I would
> appreciate getting merged into kernel release 2.6.32.
> 
> The first one is a bugfix I had already submitted for 2.6.31 but which
> seems to have fallen through the cracks. Please disregard if it's
> already present your tree.
> 
> The next eight patches provide various small bugfixes, error handling
> and documentation improvements.
> 
> The final three patches add an alternative interface to the driver,
> connecting to the Kernel CAPI subsystem instead of the obsolescent
> ISDN4Linux subsystem. They have been presented on the i4ldeveloper
> mailing list and didn't draw any protests. (In fact, no comments at
> all. I'm determined to take that as a positive sign.)
> 
> Would you please take these into your net tree for 2.6.32.

patches 6,7,10, and 12 all have checkpatch errors. Could you fix those? 

Daniel
