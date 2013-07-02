From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: convert lls to use time_in_range()
Date: Tue, 02 Jul 2013 12:56:06 -0700 (PDT)
Message-ID: <20130702.125606.2222663509004529601.davem@davemloft.net>
References: <51D2919F.7050007@linux.intel.com>
	<51D29329.4060004@linux.intel.com>
	<51D2A246.3000705@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	willemb@google.com, erdnetdev@gmail.com, andi@firstfloor.org,
	hpa@zytor.com, devel-lists@codyps.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D2A246.3000705@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Tue, 02 Jul 2013 12:49:58 +0300

> @@ -403,7 +403,8 @@ int do_select(int n, fd_set_bits *fds, struct
> timespec *end_time)

Your email client has corrupted this patch, please repost with this
issue corrected.

Thanks.
