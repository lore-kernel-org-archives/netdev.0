From: Roger Luethi <rl@hellgate.ch>
Subject: [0/9] via-rhine: Major surgery
Date: Tue, 15 Jun 2004 19:47:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615174732.GA10241@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This set of patches obsoletes all via-rhine patches for 2.6 that didn't
make it into 2.6.7-rc3-mm2. Most notable changes: I rewrote the media,
PHY, and link state handling and added WOL support for Rhine chips.

Patches [1/9] and [2/9] are resends so you won't have to go hunt them
down before trying the rest.

These patches need review and testing, especially from people with
WOL-capable hardware.

Roger
