From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
Date: Sat, 23 Aug 2008 02:29:34 -0700 (PDT)
Message-ID: <20080823.022934.127206564.davem@davemloft.net>
References: <46A00B48CC54E4468EF6911F877AC4CA018D73BB@blrx3m10.blr.amer.dell.com>
	<20080823.012830.262443664.davem@davemloft.net>
	<46A00B48CC54E4468EF6911F877AC4CA018D73BC@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com
To: Shyam_Iyer@Dell.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <46A00B48CC54E4468EF6911F877AC4CA018D73BC@blrx3m10.blr.amer.dell.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <Shyam_Iyer@Dell.com>
Date: Sat, 23 Aug 2008 14:37:53 +0530

> Exactly. And I am also suggesting that the driver version is not
> standard among different vendors.

It should not be standardized because every driver maintainer works
differently, and every driver is developed differently, and therefore
has different needs and desires for the version number.

All that matters is that the driver version makes sense to the
person maintaining the driver, and works for them when reviewing
bug reports.

Look, what you're suggesting is to change existing practice and that
doesn't belong in the discussion of the review of a specific driver.
If you want to bring that up as a topic and change globally how that
is handled, bring that up as a seperate topic on linux-kernel.

Don't bug the poor driver submitter who is just following existing
and accepted practice.
