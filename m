From: Olaf Hering <olh@suse.de>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Wed, 2 Feb 2005 23:52:58 +0100
Message-ID: <20050202225258.GA15563@suse.de>
References: <20050202133851.GA9680@suse.de> <20050202222516.GA15440@suse.de> <20050202223853.GA29237@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@oss.sgi.com
To: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Content-Disposition: inline
In-Reply-To: <20050202223853.GA29237@ti64.telemetry-investments.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Wed, Feb 02, Bill Rugolsky Jr. wrote:

> I don't have time to look now [I'm running for the door],
> but that's possibly the vmalloc() limit of 64M (67108864) ?

maybe.
->size is a userprovided value, havent looked closely at iptables
source. It seems we have to live with this limitation.
