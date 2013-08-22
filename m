From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy poll
Date: Thu, 22 Aug 2013 13:14:02 -0700 (PDT)
Message-ID: <20130822.131402.362258965058758270.davem@davemloft.net>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, eilong@broadcom.com,
	amirv@mellanox.com, erdnetdev@gmail.com, willemb@google.com,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Wed, 21 Aug 2013 13:39:54 +0300

> +	SK_LL_STATE_MISS_2,	/* data came through napi poll twice in a row */

Please rename this to SK_LL_STATE_MISS_MULTI or something like that.

Thanks.
