From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Don't pass invalid dst_entry pointer to
 dst_release().
Date: Mon, 04 Apr 2011 13:07:39 -0700 (PDT)
Message-ID: <20110404.130739.209975217.davem@davemloft.net>
References: <1301946910-5530-1-git-send-email-ostr@amd64.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	boris.ostrovsky@amd.com
To: ostr@amd64.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301946910-5530-1-git-send-email-ostr@amd64.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Boris Ostrovsky <ostr@amd64.org>
Date: Mon,  4 Apr 2011 15:55:10 -0400

> From: Boris Ostrovsky <boris.ostrovsky@amd.com>
> 
> Make sure dst_release() is not called with error pointer. This is
> similar to commit 4910ac6c526d2868adcb5893e0c428473de862b5.
> 
> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@amd.com>

Applied, thank you.
