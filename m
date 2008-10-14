From: David Miller <davem@davemloft.net>
Subject: Re: e1000 softirq load balancing
Date: Tue, 14 Oct 2008 16:51:09 -0700 (PDT)
Message-ID: <20081014.165109.199128881.davem@davemloft.net>
References: <48F4ED7E.4070308@cs.utexas.edu>
	<20081014.125156.92616351.davem@davemloft.net>
	<48F52F43.9040201@cs.utexas.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: porterde@cs.utexas.edu
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <48F52F43.9040201@cs.utexas.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Don Porter <porterde@cs.utexas.edu>
Date: Tue, 14 Oct 2008 18:46:11 -0500

> Would you mind giving me a bit of intuition why I can't have a 1:1
> mapping of CPUs to NICs?

I didn't say that.

I said that without HW flow seperation support, you can only
expect N cpus to be busy where N is the number of NICs you
have.
