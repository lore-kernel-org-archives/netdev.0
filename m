From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 21:54:35 -0800
Message-ID: <CA+55aFyU2nxQ=8c7CdRo4EUOBwf0R2sFJ243qF94O4JSrA0nrw@mail.gmail.com>
References: <CA+55aFxgNOdXonyKXRnKfyLM57_e4EpP+VYr6taUf2Bh5gCg9w@mail.gmail.com>
	<20150211040245.GD29656@ZenIV.linux.org.uk>
	<CA+55aFyyMXWH1cfyB+fUX8jwngjzemiAgoZdKJogs_Pae9m+Xw@mail.gmail.com>
	<20150210.212849.430372584863698846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150210.212849.430372584863698846.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 9:28 PM, David Miller <davem@davemloft.net> wrote:
>
> I've put Al's version of the fix into my tree and here is
> a new respun pull request:

Heh. I already faked that myself - fetched your branch, then locally
added my fix on top of it, and merged that instead.

So I have "pulled" the networking branch, even if it was a slightly edited one.

Btw, I like your summaries for the networking pulls, but they don't
tend to mention a lot of the stuff that I assume you pull from others.
For example, there seems to  have been a lot of bluetooth stuff this
round and obviously there's just a ton of network driver work, but
those tend to not be mentioned in your summary - presumablty because
most of that is a few people removed. I'm wondering if you could add
*some* mention of things like that to the summaries too?

                          Linus
