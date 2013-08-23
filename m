From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy poll
Date: Fri, 23 Aug 2013 10:06:15 +0300
Message-ID: <521709E7.7000302@linux.intel.com>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com> <20130822.131402.362258965058758270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, eilong@broadcom.com,
	amirv@mellanox.com, erdnetdev@gmail.com, willemb@google.com,
	eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130822.131402.362258965058758270.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/08/2013 23:14, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Wed, 21 Aug 2013 13:39:54 +0300
> 
>> +	SK_LL_STATE_MISS_2,	/* data came through napi poll twice in a row */
> 
> Please rename this to SK_LL_STATE_MISS_MULTI or something like that.
> 
> Thanks.

OK
