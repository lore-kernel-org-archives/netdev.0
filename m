From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: sunhme stopped working somewhere in 2.6.0-test4
Date: Sat, 6 Sep 2003 21:45:01 -0700
Sender: sparclinux-owner@vger.kernel.org
Message-ID: <20030907044501.GC33595@gaz.sfgoth.com>
References: <20030907043151.GB33595@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <sparclinux-owner@vger.kernel.org>
To: sparclinux@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20030907043151.GB33595@gaz.sfgoth.com>
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr wrote:
> ...and the operation fails.  It looks like there's been a number of changes
> to sunhme in the last week (ethtool stuff, maybe some other things)....

BTW, it turns out that this stuff is NOT the problem; I just tried copying
the 2.6.0-test4 version of sunhme.c into my tree (and verified that I now
have driver version "2.01" instead of "2.02" in dmesg), but I still have
the same problem.  So something broke, but I guess the problem is deeper...

-Mitch
