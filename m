From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3
Date: Fri, 8 Oct 2004 22:31:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008203114.GD19628@postel.suug.ch>
References: <20041008104801.0dd96536.akpm@osdl.org> <20041008181036.GC19714@rei.reeler.org> <4166F224.4020801@alfarrabio.di.uminho.pt> <20041008132128.4d5a5a4a.akpm@osdl.org> <4166F638.80502@alfarrabio.di.uminho.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alberto Manuel Brandao Simoes <albie@alfarrabio.di.uminho.pt>
Content-Disposition: inline
In-Reply-To: <4166F638.80502@alfarrabio.di.uminho.pt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Alberto Manuel Brandao Simoes <4166F638.80502@alfarrabio.di.uminho.pt> 2004-10-08 21:19
> I've sent it.
> Here it is again.

Nothing suspicious in that dump, SACK, slow start and termination look
all ok. No networking fault involved here, so I guess this is not
related to Andrew's issue. Judging from your other mail regarding
the failure of man I'd say it's related to a filesystem or hardware
problem.
