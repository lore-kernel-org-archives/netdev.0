From: Shirley Ma <xma@us.ibm.com>
Subject: Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 14 Sep 2007 11:36:12 -0700
Message-ID: <OF1B5CCF10.3CE4B194-ON87257356.00661AD2-88257356.0065F05E@us.ibm.com>
References: <adazlzpjkk6.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753246AbXINSg1@vger.kernel.org>
In-Reply-To: <adazlzpjkk6.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> IPoIB CM handles this properly by gathering together single pages in
> skbs' fragment lists.
> 
>  - R.

Then can we reuse IPoIB CM code here?

Thanks
Shirley 
