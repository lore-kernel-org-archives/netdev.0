From: Jason Lunz <lunz@falooley.org>
Subject: Re: How can we bound one CPU to one Gigabit NIC?
Date: Tue, 8 Oct 2002 17:41:36 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnaq667h.ntv.lunz@stoli.localnet>
References: <010001c26e9c$2319c480$f5f2010a@weixl> <Pine.GSO.4.30.0210080455440.8988-100000@shell.cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hadi@cyberus.ca said:
> Can you repeat these tests with NAPI and no binding and see if you get
> any reordering?

Wouldn't he need a NAPIfied SysKonnect driver? I wasn't aware anyone had
converted it yet. Or is it enough for him to check the blog_dev path?

Jason
