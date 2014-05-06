From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 19/24] net, diet: Make RPS configurable
Date: Tue, 6 May 2014 05:16:21 +0200
Message-ID: <20140506031621.GO2382@two.firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-20-git-send-email-andi@firstfloor.org>
 <20140505.231433.1853863657752503508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140505.231433.1853863657752503508.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 05, 2014 at 11:14:33PM -0400, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon,  5 May 2014 15:26:08 -0700
> 
> > Multiple receive queues are not needed on small systems,
> > so allow disabling them.
> 
> It's only enabled with SMP...

You didn't read the whole description, did you?

-Andi
