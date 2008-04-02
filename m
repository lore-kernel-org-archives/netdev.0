From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 19:56:05 +0900
Message-ID: <20080402195428.95A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080402.012406.246863209.davem@davemloft.net> <20080402175857.959A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, csnook@redhat.com,
	davej@codemonkey.org.uk, nickpiggin@yahoo.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755491AbYDBK5P@vger.kernel.org>
In-Reply-To: <20080402175857.959A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> ---------------------------------------------------------------------
> We get rather a lot of reports of page allocation warnings coming out of
> tg3.  But this driver is know to handle them properly so let's suppress
> them.

BTW:
other person's tg3 allocation failure bug report.

http://bugzilla.kernel.org/show_bug.cgi?id=9771
