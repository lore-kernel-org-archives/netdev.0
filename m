From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
Date: Mon, 22 Sep 2003 18:07:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922180749.A26432@infradead.org>
References: <200309221703.h8MH3tkT009109@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200309221703.h8MH3tkT009109@ginger.cmf.nrl.navy.mil>; from chas@cmf.nrl.navy.mil on Mon, Sep 22, 2003 at 01:03:57PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Umm, shouldn't you just ifdef out the whole function and it's
assignment to the operations vector?  This looks horribly ugly..
