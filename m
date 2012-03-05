From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] qla3xxx: ethernet: Silence static checker warning.
Date: Mon, 05 Mar 2012 16:53:58 -0500 (EST)
Message-ID: <20120305.165358.1299012386498157182.davem@davemloft.net>
References: <1330700979-18231-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330700979-18231-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: santosh nayak <santoshprasadnayak@gmail.com>
Date: Fri,  2 Mar 2012 20:39:39 +0530

> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> Silence the following warning:
> "warn: returning -1 instead of -ENOMEM is sloppy".
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>

Applied.
