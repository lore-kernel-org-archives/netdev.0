From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFT] net: Change niu_rbr_fill() to use unlikely() to
 check niu_rbr_add_page() return value
Date: Sun, 22 Jul 2012 23:35:06 -0700 (PDT)
Message-ID: <20120722.233506.850170096735613796.davem@davemloft.net>
References: <1342827272.5434.71.camel@lorien2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shuahkhan@gmail.com
To: shuah.khan@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342827272.5434.71.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 20 Jul 2012 17:34:32 -0600

> Change niu_rbr_fill() to use unlikely() to check niu_rbr_add_page() return
> value to be consistent with the rest of the checks after niu_rbr_add_page()
> calls in this file.
> 
> Signed-off-by: Shuah Khan <shuah.khan@hp.com>

Applied.
