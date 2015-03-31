From: David Miller <davem@davemloft.net>
Subject: Re: [net] Intel Wired LAN Driver Updates
Date: Tue, 31 Mar 2015 13:22:14 -0400 (EDT)
Message-ID: <20150331.132214.1693397186943204005.davem@davemloft.net>
References: <1427497451-23642-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, linux.nics@intel.com,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427497451-23642-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Mar 2015 16:04:10 -0700

> The following are changes since commit dde93dfea53c72b07907d9e44a6e4b1545f6bdc4:
>   cxgb4: Fix frame size warning for 32 bit arch
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master
> 
> Jeff Kirsher (1):
>   MAINTAINERS: Update Intel Wired Ethernet Driver info

Looks great but it looks like nothing is pushed there?

[davem@localhost net]$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master
>From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
 * branch            master     -> FETCH_HEAD
Already up-to-date.
[davem@localhost net]$
