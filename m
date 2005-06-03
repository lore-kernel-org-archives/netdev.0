From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] PKT_SCHED related fixes and a meta ematch completion
Date: Fri, 03 Jun 2005 23:12:41 +0200
Message-ID: <20050603211241.593114000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

The following patchset fixes some serious bugs that prevent
the basic classifier and the meta ematch from working properly.
Patch 2 adds a few new meta collectors for socket attribtues which
I'd like to have in 2.6.12 as well. If you think this is too
intrusive (it isn't ;->) I'll resend patch 4 with offsets fixed.

Thanks.
