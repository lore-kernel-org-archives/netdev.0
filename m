From: Jeff Garzik <jgarzik@pobox.com>
Subject: sexy sendfile?
Date: Sat, 28 Dec 2002 15:54:14 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021228205414.GA30388@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

IIRC from a post a month or so ago, Linus mentioned that current 2.5.x
no longer had deadlock issues for file->file sendfile, which leads me to
wonder aloud,

Does this mean file->file sendfile can now be official supported in 2.5.x?

And more interesting, [thus the CC to netdev]
can we support socket->socket sendfile?

	Jeff
