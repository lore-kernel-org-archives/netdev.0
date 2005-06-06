From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCHSET] PKT_SCHED related fixes and a meta ematch completion
Date: Mon, 06 Jun 2005 15:29:13 -0700 (PDT)
Message-ID: <20050606.152913.88479223.davem@davemloft.net>
References: <20050603211241.593114000@axs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050603211241.593114000@axs>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 03 Jun 2005 23:12:41 +0200

> The following patchset fixes some serious bugs that prevent
> the basic classifier and the meta ematch from working properly.
> Patch 2 adds a few new meta collectors for socket attribtues which
> I'd like to have in 2.6.12 as well. If you think this is too
> intrusive (it isn't ;->) I'll resend patch 4 with offsets fixed.

I'll try to get these 4 patches into 2.6.12, they all look
straight forward and sane to me.

Thanks Thomas.
