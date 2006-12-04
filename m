From: Daniel Drake <dsd@gentoo.org>
Subject: Re: d80211-drivers updated (zd1211rw-d80211 synced with zd1211rw)
Date: Mon, 04 Dec 2006 09:03:50 -0500
Message-ID: <45742AC6.90408@gentoo.org>
References: <200612040250.43955.flamingice@sourmilk.net> <20061204125139.GA10912@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:53130 "EHLO
	smtp151.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S936875AbWLDOL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 09:11:57 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061204125139.GA10912@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Similarly, I would prefer for Ulrich or Daniel to maintain the zd1211rw
> git tree unless you (i.e. Michael) are going to be one of the primary
> authors going forward.

OK. Myself and Ulrich have discussed this, we are going to create our 
own git trees for zd1211rw-d80211.

The attraction of sending pull requests to Michael is that he should be 
able to merge patches and push out updated trees quicker. If the 
turnaround is quicker here it would really mean we could stop having to 
maintain our own git stuff and simply use the upstream tree as the base.

However, this isn't really a big deal: Ulrich wants to use git 
regardless, and I'm still the patch monkey, so I will continue using git 
as well (regardless of upstream merge time turnaround).

Daniel
