From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] vxge: Remove useless return variables
Date: Mon, 02 Jun 2014 17:02:58 -0700 (PDT)
Message-ID: <20140602.170258.144328105696750793.davem@davemloft.net>
References: <1401542051-3174-10-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401542051-3174-10-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Sat, 31 May 2014 10:14:10 -0300

> This patch remove variables that are initialized with a constant,
> are never updated, and are only used as parameter of return.
> Return the constant instead of using a variable.
> 
> Verified by compilation only.
...
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied.
