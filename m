From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET 0/6] PKT_SCHED: Generic classifier routines / cls_fw cleanup
Date: Fri, 29 Oct 2004 02:21:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002113.GY12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

The following patchset is basically what we discussed before
but without the tcf_filter bits because it's not really worth
it. It will save us ~100 lines of code per classifier.

I tested the already splitted patchset this time :->

Jamal, I tried to test the action stuff as good as possible, but
can you give it a run with your test scripts?

I will submit a 2.4 version for patch 6 in a few minutes.

Cheers
