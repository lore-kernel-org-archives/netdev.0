From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] OpenCores 10/100 MAC ethtool operations
Date: Sat, 01 Feb 2014 16:57:23 -0800 (PST)
Message-ID: <20140201.165723.159807875655406849.davem@davemloft.net>
References: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@decadent.org.uk, f.fainelli@gmail.com, marc@cadence.com
To: jcmvbkbc@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Max Filippov <jcmvbkbc@gmail.com>
Date: Fri, 31 Jan 2014 09:41:03 +0400

> Hello David, Ben, Florian and everybody,
> 
> this series implements ethtool callbacks for the ethoc driver as was
> requested by Florian.
> 
> Changes v1->v2:
> - fix {get,set}_settings return code in case there's no PHY;
> - fix set_ringparam: check ring sizes, change ring sizes on the fly.

Series applied, thanks.
