From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] [VIA RHINE] older chips oops on shutdown
Date: Tue, 22 Mar 2005 08:30:39 +0100
Message-ID: <20050322073039.GA15540@k3.hellgate.ch>
References: <20050305184056.GA11056@austin.ibm.com> <20050321145616.192afadc.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olof Johansson <olof@austin.ibm.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050321145616.192afadc.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 14:56:16 -0800, Andrew Morton wrote:
> Roger, are you OK with merging this patch?

Uhm, it's been merged in mainline more than two weeks ago, no? Denying
access to non-existant registers is the right thing to do (an equivalent
is already in rhine_power_init).

Roger
