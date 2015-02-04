From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tlan: msecs_to_jiffies convrsion
Date: Wed, 04 Feb 2015 13:58:50 -0800 (PST)
Message-ID: <20150204.135850.109188095612349631.davem@davemloft.net>
References: <1422953111-19840-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chessman@tux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422953111-19840-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Tue,  3 Feb 2015 03:45:11 -0500

> This is only an API consolidation and should make things more readable
> it replaces var * HZ / 1000 by msecs_to_jiffies(var).
> 
> As there is a discrepancy between the code and the comments this is in
> a separate patch.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied.
