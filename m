From: David Heidelberger <david.heidelberger@ixit.cz>
Subject: [announce] iputils-s20140519
Date: Tue, 20 May 2014 01:51:36 +0200
Message-ID: <c8c39c82140abf2b623eb6edc21f128e@ixit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: jsynacek@redhat.com, david@gibson.dropbear.id.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94-84-246-161.wendulka.net ([84.246.161.94]:39344 "EHLO ixit.cz"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbaESWwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 18:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'd like to announce new iputils s20140519. Can be downloaded from [1].

It does include many fixes, gathered from various contributors. All has 
been reviewed and tested.
Many of these patches has been already in distributions like Debian, 
Fedora or Gentoo.
This release is tested with glibc, uClibc and musl-libc.

Changes can be seen here [2].

Roadmap for upcomming release: unify ping and ping6, allow choose IPV4 
or IPV6 by passing -4 or -6. Any help welcome :)

Also I'd like to thank all people who contributed to this release :)

Best regards
David Heidelberger

P.S. travis-ci build fail is caused by their change in processing 
.travis.yml on some workers. As you can see, previous commit before tag 
commit has all builds passed.

[1] https://github.com/iputils/iputils/releases
[2] https://github.com/iputils/iputils/commits/master
