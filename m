From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][v4][0/24] Second InfiniBand merge
	candidate patch set
Date: Mon, 27 Dec 2004 21:19:26 -0800
Message-ID: <52k6r3j8yp.fsf@topspin.com>
References: <200412192214.KlDxQ7icOmxHYIf0@topspin.com>
	<20041220.153845.70996857.yoshfuji@linux-ipv6.org>
	<20041227210007.398734cd.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	torvalds@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041227210007.398734cd.davem@davemloft.net> (David S.
	Miller's message of "Mon, 27 Dec 2004 21:00:07 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> If Roland can resubmit his patch queue to me with the fixes
    David> folks have recommended to him, I can start merging this
    David> stuff in.

Andrew has indicated to me that he has merged the whole InfiniBand
patch into -mm now.

Dave, did you want to handle the entire merge of the whole IB stack,
or just the net/ parts, which are pretty trivial and stand alone,
since AF_INFINIBAND is already defined in the tree?

I'm happy to do whatever it takes to get IB merged as expeditiously as
possible so Dave & Andrew, please let me know what seems easiest and
best to you.

Thanks,
  Roland
