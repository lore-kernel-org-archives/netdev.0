From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] netfilter: netfilter fixes
Date: Wed, 09 Feb 2011 12:40:10 -0800 (PST)
Message-ID: <20110209.124010.71105932.davem@davemloft.net>
References: <1297262369-26393-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1297262369-26393-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kaber@trash.net
Date: Wed,  9 Feb 2011 15:39:28 +0100

> Hi Dave,
> 
> following is a single netfilter fix for net-2.6.git, fixing use of conntrack
> templates when TCP conntrack kills the current conntrack in TIME_WAIT state
> in order to have the conntrack core create a fresh one, from Pablo.
> 
> Please pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Also pulled, thanks a lot.
