From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 3 Jul 2013 09:51:14 +0200
Message-ID: <CA+icZUW53Rdh6PbsVJVGTH3-HAx=0pOO_o5MixdC_ZpBKrO71w@mail.gmail.com>
References: <20130703174822.d06500db5cbd5191c39e3f08@canb.auug.org.au>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130703174822.d06500db5cbd5191c39e3f08@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 3, 2013 at 9:48 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> After merging the final tree, today's linux-next build (powerpc
> allnoconfig) failed like this:
[...]
> Caused by commit 1bc2774d8664 ("net: convert lls to use time_in_range()")
> from the net-next tree.
>
> I cherry-picked the commit 419076f59fc5 ("net: lls fix build with
> allnoconfig") out of tomorrow's net-next tree.  (I am feeling generous
> and noticed that patch being applied :-))
>

/me loves generous coders and shy girls.

- Sedat -

> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
