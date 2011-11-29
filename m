From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 14:39:50 -0500 (EST)
Message-ID: <20111129.143950.406285357.davem@davemloft.net>
References: <028246D6-9024-4E43-93A1-25A87878CBBC@gmail.com>
	<20111129.011932.1501413448765180498.davem@davemloft.net>
	<BC344CCF-A50F-4E5E-A9A5-F506D8BD9DB9@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, vladislav.yasevich@hp.com,
	sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: xi.wang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BC344CCF-A50F-4E5E-A9A5-F506D8BD9DB9@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>
Date: Tue, 29 Nov 2011 14:31:30 -0500

> a5e5c374 --- it says "No differences found".
> 
> Can you please apply the new patch v2?  Thanks.

Sigh, probably a side effect of how your patch was corrupted
and how I tried to fix it up by hand :-/

Ok, I'll apply v2, thanks.
