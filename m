From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Tue, 25 Apr 2017 11:17:17 -0400 (EDT)
Message-ID: <20170425.111717.1973239615715123840.davem@davemloft.net>
References: <20170425.104731.631398016575024152.davem@davemloft.net>
	<20170425150419.2060-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 David.Laight@aculab.com, kernel-hardening@lists.openwall.com
To: Jason@zx2c4.com
Return-path: <kernel-hardening-return-7563-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170425150419.2060-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org


John this isn't how it works.

When you submit new versions of a patch that are part of a patch
series, you must resubmit the entire series not just the patches which
are changing.

Thanks.
