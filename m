From: Shuah Khan <shuah.khan@hp.com>
Subject: Re: [PATCH RFT] net: Fix Neptune ethernet driver to check dma
 mapping error
Date: Fri, 20 Jul 2012 15:36:37 -0600
Message-ID: <1342820197.5434.54.camel@lorien2>
References: <1342819679.5434.50.camel@lorien2>
	 <20120720.143005.135422510157595877.davem@davemloft.net>
Reply-To: shuah.khan@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120720.143005.135422510157595877.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-20 at 14:30 -0700, David Miller wrote:
> From: Shuah Khan <shuah.khan@hp.com>
> Date: Fri, 20 Jul 2012 15:27:59 -0600
> 
> > Request for testing, since I don't have the hardware to test.
> 
> This is not how you post a patch.
> 
> > --------------------------------------------------------------------
> 
> When you put those "---..." there, GIT is going to eliminate everything
> afterwards from the commit mesage when I apply this.  Yet afterwards
> is what your commit message actually is.
> 
> You therefore should do things the other way around, provide the commit
> message text, then the "---..." line, then your comments you don't want
> in the final commit message.

Thanks. I had it reversed in my head for some reason. Maybe not enough
coffee :) Will resend the patch now.

-- Shuah
