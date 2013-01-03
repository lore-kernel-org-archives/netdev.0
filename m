From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 02 Jan 2013 19:28:48 -0800 (PST)
Message-ID: <20130102.192848.1391048999163570664.davem@davemloft.net>
References: <20130103142353.b4fee0ccd57730e4fbd63ba9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, sony.chacko@qlogic.com,
	sucheta.chakraborty@qlogic.com, sritej.velaga@qlogic.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130103142353.b4fee0ccd57730e4fbd63ba9@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 3 Jan 2013 14:23:53 +1100

> Caused by commit 13159183ec7a ("qlcnic: 83xx base driver") from the
> net-next tree.  Why is this commit adding a function that already exists
> globally?

And this is after I pushed back on this patch series 5 times or so.

You qlogic guys, can you see why I give you such a hard time with
your patch submissions?  Even after I ask you to correct all of the
most obvious problems, there is still garbage like this that shows
up in your changes.

What in the world do I have to do, other than push back on your
submissions even harder, to keep crap like this from happening
in the future?

Tell me.

You, as a group, are the absolute worst networking driver submitters.

This is a real problem because you submit large bodies of code that 1)
nobody wants to review and 2) has a very small user base.  So you
impart an extremely large burdon upon me, in particular, because I'm
the only person that actually reviews your code at all.
