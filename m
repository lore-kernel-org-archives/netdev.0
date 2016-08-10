From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: use proper names for suspend/resume functions
Date: Wed, 10 Aug 2016 14:52:17 -0700 (PDT)
Message-ID: <20160810.145217.313553520154842617.davem@davemloft.net>
References: <20160810110949.16608-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, wsa@the-dreams.de
To: niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160810110949.16608-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Date: Wed, 10 Aug 2016 13:09:49 +0200

> The patch 'ravb: add sleep PM suspend/resume support' used incorrect
> function names containing 'runtime' for the suspend and resume
> functions.
> 
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

Applied, thanks.
