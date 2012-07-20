From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFT] net: Fix Neptune ethernet driver to check dma
 mapping error
Date: Fri, 20 Jul 2012 14:30:05 -0700 (PDT)
Message-ID: <20120720.143005.135422510157595877.davem@davemloft.net>
References: <1342819679.5434.50.camel@lorien2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shuahkhan@gmail.com,
	stable@vger.kernel.org
To: shuah.khan@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342819679.5434.50.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 20 Jul 2012 15:27:59 -0600

> Request for testing, since I don't have the hardware to test.

This is not how you post a patch.

> --------------------------------------------------------------------

When you put those "---..." there, GIT is going to eliminate everything
afterwards from the commit mesage when I apply this.  Yet afterwards
is what your commit message actually is.

You therefore should do things the other way around, provide the commit
message text, then the "---..." line, then your comments you don't want
in the final commit message.
