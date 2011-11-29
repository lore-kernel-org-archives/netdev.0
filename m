From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 14:31:30 -0500
Message-ID: <BC344CCF-A50F-4E5E-A9A5-F506D8BD9DB9@gmail.com>
References: <028246D6-9024-4E43-93A1-25A87878CBBC@gmail.com> <20111129.011932.1501413448765180498.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, vladislav.yasevich@hp.com,
	sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111129.011932.1501413448765180498.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry my bad.

BTW it seems that the patch was not applied correctly either in
the commit a5e5c374 --- it says "No differences found".

Can you please apply the new patch v2?  Thanks.

- xi

On Nov 29, 2011, at 1:19 AM, David Miller wrote:
> 
> Applied, but I had to apply your patch by hand because it was
> corrupted by your email client.
> 
> Please fix this problem because I am not applying any other patch
> you've submitted which has this issue.
