From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patches try2] 2.6.x net driver updates
Date: Wed, 25 May 2005 19:03:39 -0400
Message-ID: <4295044B.7090604@pobox.com>
References: <4294BD9C.2050105@pobox.com> <Pine.LNX.4.58.0505251200040.2307@ppc970.osdl.org> <42950334.9090402@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <42950334.9090402@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Not specialized at all.  I do one pull at a time, so git-pull-script 
> suffices with a simple addition to call git-resolve-script with the 
> branch as $4, and a simple addition to git-resolve-script to add 'branch 

Correction: new $4 arg was added to git-resolve-script, not git-pull-script
