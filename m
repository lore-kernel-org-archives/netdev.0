From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] Extended matches and basic classifier
Date: Mon, 24 Jan 2005 00:00:12 +0100
Message-ID: <20050123230012.GB23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patchset adds the ematch API, the ematches cmp, nbyte, u32, meta,
and the basic classifier. It doesn't touch any existing code.

The following changes were made since the last review:
 - various typo and bug fixes
 - macro for meta data collectors (beautification)
 - some more comments

The required changes for iproute2 can be pulled from:
  bk://tgr.bkbits.net/iproute2-tgr

The iproute2 part still has quite some potential for improvements to
ease usability though.

Cheers, Thomas
