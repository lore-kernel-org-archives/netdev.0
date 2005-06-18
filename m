From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 0/9] orinoco updates
Date: Sun, 19 Jun 2005 01:27:10 +0200
Message-ID: <20050618232710.GA9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a tweleve patch series to bring orinoco in mainline uptodate with CVS.
I've also use the new ieee80211.h constants from the Jeff's wireless
tree, so the first patch brings over a copy of that one.

I'm mentioning the original authors wherever I could find them out, but most
patches actually consists of various CVS commits that belong together
logically.
