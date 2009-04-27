From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxacru: Fix negative dB output
Date: Mon, 27 Apr 2009 03:22:24 -0700 (PDT)
Message-ID: <20090427.032224.88109207.davem@davemloft.net>
References: <49F0A306.9010409@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755167AbZD0KWp@vger.kernel.org>
In-Reply-To: <49F0A306.9010409@simon.arlott.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Thu, 23 Apr 2009 18:19:02 +0100

> Values of dB between -0.99 and -0.01 will be output with the wrong
> sign. This converts the negative value to positive and outputs it
> with a "-" prefix.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Applied to net-next-2.6, thanks.
