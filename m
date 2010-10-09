From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tg3: simplify conditional
Date: Sat, 09 Oct 2010 09:23:53 -0700 (PDT)
Message-ID: <20101009.092353.57476425.davem@davemloft.net>
References: <20101008112927.0ca949cf@absol.kitzblitz>
	<20101008174312.GA3562@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikai@nikai.net, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101008174312.GA3562@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 8 Oct 2010 10:43:12 -0700

> On Fri, Oct 08, 2010 at 02:29:27AM -0700, Nicolas Kaiser wrote:
>> Simplify: ((a && !b) || (!a && b)) => (a != b)
>> 
>> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
 ...
> Looks good to me.

Applied.

Matt, you can give an "Acked-by: " tag to indicate your approval
of a patch in the future :-)

Thanks.
