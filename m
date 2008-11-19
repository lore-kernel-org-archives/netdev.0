From: Matt Mackall <mpm@selenic.com>
Subject: Re: next-20081117: kernel freezes with netconsole enabled
Date: Wed, 19 Nov 2008 12:27:31 -0600
Message-ID: <1227119251.3149.57.camel@calx>
References: <20081119175740.GE12456@orion>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, satyam.sharma@gmail.com
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081119175740.GE12456@orion>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-11-19 at 20:57 +0300, Alexander Beregalov wrote:
> Hi 
> 
> It is x86_64 SMP
> The kernel freezes while transferring kernel log through netconsole,
> SysRq does not work at that moment.

Does it survive if you boot with 'quiet'? Is this new behavior or have
you successfully used netconsole before?

-- 
Mathematics is the supreme nostalgia of our time.
