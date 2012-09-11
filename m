From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scsi_netlink: Remove dead and buggy code
Date: Tue, 11 Sep 2012 18:48:46 -0400 (EDT)
Message-ID: <20120911.184846.1973557158791638595.davem@davemloft.net>
References: <20120910.150700.1197774171539303770.davem@davemloft.net>
	<1347314879.3038.74.camel@dabdike.int.hansenpartnership.com>
	<878vcggp4n.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org,
	James.Smart@Emulex.Com, linux-scsi@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <878vcggp4n.fsf@xmission.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Sep 2012 15:40:08 -0700

> So just for curiosity I searched the entire git history for scsi_nl_add_
> and the only commit that I found was the addition of that code to the
> tree in August of 2008.
> 
> Does anyone have any reason to keep scsi_nl_add_transport or
> scsi_nl_add_driver that have never been used in the 4 years since
> they have been added?

That's basically the question on the table right now :-)
