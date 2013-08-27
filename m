From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Rename nsproxy.pid_ns and fix a related security
 bug
Date: Tue, 27 Aug 2013 13:53:11 -0400 (EDT)
Message-ID: <20130827.135311.363272748428277447.davem@davemloft.net>
References: <cover.1377196394.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, security@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1377196394.git.luto@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 22 Aug 2013 11:39:14 -0700

> Eric fell for my bogus claim that nsproxy->pid_ns was the current'
> process's pid ns.  This isn't true.
> 
> Let's fix the bug and rename pid_ns so that no one gets this wrong again.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Series applied, thanks.
