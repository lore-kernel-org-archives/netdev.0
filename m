From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add getsockopt support for TCP thin-streams
Date: Mon, 02 Aug 2010 17:25:38 -0700 (PDT)
Message-ID: <20100802.172538.220060944.davem@davemloft.net>
References: <1280533775-7700-1-git-send-email-johunt@akamai.com>
	<4C56B018.8030309@simula.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com
To: apetlund@simula.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C56B018.8030309@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Petlund <apetlund@simula.no>
Date: Mon, 02 Aug 2010 13:46:32 +0200

> On 07/31/2010 01:49 AM, Josh Hunt wrote:
>> Initial TCP thin-stream commit did not add getsockopt support for the new
>> socket options: TCP_THIN_LINEAR_TIMEOUTS and TCP_THIN_DUPACK. This adds support
>> for them.
>> 
>> Signed-off-by: Josh Hunt <johunt@akamai.com>
 ...
> Tested-by: Andreas Petlund <apetlund@simula.no>
> Acked-by: Andreas Petlund <apetlund@simula.no>

Applied, thanks.
