From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
Date: Mon, 22 Sep 2003 13:55:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309221755.h8MHt5kT010184@ginger.cmf.nrl.navy.mil>
References: <hch@infradead.org>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: Message from Christoph Hellwig <hch@infradead.org>
   of "Mon, 22 Sep 2003 18:07:50 BST." <20030922180749.A26432@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030922180749.A26432@infradead.org>,Christoph Hellwig writes:
>Umm, shouldn't you just ifdef out the whole function and it's
>assignment to the operations vector?  This looks horribly ugly..

i suppose i am not convinced that two #ifdef/#endif's are better than an
#if/#else/#endif
