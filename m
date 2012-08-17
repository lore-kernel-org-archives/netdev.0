From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage in xfrm_net_init()
Date: Thu, 16 Aug 2012 19:41:29 -0700 (PDT)
Message-ID: <20120816.194129.1416562963060076374.davem@davemloft.net>
References: <20120816151949.GA18681@localhost>
	<502D9938.2010908@windriver.com>
	<CAP=VYLqHW+NOS-gPgUkUpZh-Vim2jkmMT7NK+7uRbg730d=xHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, fengguang.wu@intel.com,
	Priyanka.Jain@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLqHW+NOS-gPgUkUpZh-Vim2jkmMT7NK+7uRbg730d=xHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 16 Aug 2012 21:34:25 -0400

> Also, a patch should describe the problem it solves (i.e. the symptom
> the end user sees), and how the problem originated, and why the fix
> in the patch is the _right_ fix.  The worst description a commit log
> can have is one that just describes the C change in words, since
> most people can read C on their own.

I've frankly given up on Fan Du submitting sophisticated patches
that are easy to review and are properly documented.

Just getting simple things like a WORKING EMAIL ADDRESS was beyond a
struggle.

So when I get a patch that applies, from a properly working email
address, it's an accomplishment.
