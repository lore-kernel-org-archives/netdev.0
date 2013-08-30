From: ke wang <hacklinux66@gmail.com>
Subject: routing lc-trie fustrated me a lot, please help.
Date: Fri, 30 Aug 2013 14:11:49 +0800
Message-ID: <CA+NCTVqu8euF4YSCVFfQKbEAhYxiA_WVjK4KwC8KS-_mb3LX7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f68.google.com ([209.85.219.68]:34395 "EHLO
	mail-oa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab3H3GLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 02:11:49 -0400
Received: by mail-oa0-f68.google.com with SMTP id n10so351771oag.3
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 23:11:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi:
     i currently do some work on linux networking, the code version is
2.6.39, however, i think what confused me does a litte matter with the
code version. i
viewed the routing code within the kernel, the routing algorithm of
lc-trie seems very complicated. i have seen the article posted by
niclo for the explanation of lc-trie and understand the basic
principle of trie tree, path compression. while, the code still made
me very frustrated, especilly the insert and search code, i mean
fib_insert_node and fib_find_node functions. could u give me
explanation about them, aslo can u introduce me some high quality
books concerning 2.6 networking, i tried to got some from web but
failed. thx indeed, and hope hear from u .

best regards
