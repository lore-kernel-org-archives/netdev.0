From: David Miller <davem@davemloft.net>
Subject: Re: warning: massive change to conditional coding style in net?
Date: Mon, 30 Nov 2009 12:36:44 -0800 (PST)
Message-ID: <20091130.123644.203668577.davem@davemloft.net>
References: <4B13A025.7000103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753128AbZK3Ugj@vger.kernel.org>
In-Reply-To: <4B13A025.7000103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Mon, 30 Nov 2009 05:36:21 -0500

> Over the past several days, David Miller (with help from Joe Perches)
> made sweeping changes to the format of conditional statements in the
> net tree -- the equivalent of mass patches that change spaces.
> 
> This makes writing patches for multiple versions of the tree very
> difficult, and will make future pullups problematic.  It's enough to
> make a grown man cry....  Patching conflicts everywhere!

William, you're unreasonable.

We asked you to follow a certain style, and then you immediately
complain that the style isn't followed consistently in the tree, and
therefore as a consequence you shouldn't be required to follow it.

Then Joe comes and submits patches making the tree follow the style
more consistently.  See, instead of merely complaining like you did,
he proactively did something positive.

Now you're complaining because this makes your patches harder to
maintain.

You're being difficult about this from every possible angle.  I can
only conclude that for whatever reason you don't want to have any
requirements made upon you for your submission.  You've handled this
negatively in every way possible, and every step of the way.  No
matter how hard other people have been to try and help you, you've
continued to do this.

Whereas if you had merely fixed up the coding style as I and others
have asked you, your code would be in my tree weeks ago.

Why is it such a huge deal to follow the coding style that the
maintainer (and other prominent developers of that subsystem) are
asking you to follow?
