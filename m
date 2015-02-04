From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tlan: use msecs_to_jiffies for conversion
Date: Wed, 04 Feb 2015 13:58:45 -0800 (PST)
Message-ID: <20150204.135845.300698736110601072.davem@davemloft.net>
References: <1422953085-19797-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chessman@tux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422953085-19797-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Tue,  3 Feb 2015 03:44:45 -0500

> This is only an API consolidation and should make things more readable
> it replaces var * HZ / 1000 by msecs_to_jiffies(var).
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied.
