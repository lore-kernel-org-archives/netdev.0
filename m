From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm:he - Do not initialise statics to 0.
Date: Thu, 04 Jun 2015 15:43:26 -0700 (PDT)
Message-ID: <20150604.154326.859612305569867455.davem@davemloft.net>
References: <1433428860-3467-1-git-send-email-shailendra.capricorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shailendra.capricorn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433428860-3467-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shailendra Verma <shailendra.capricorn@gmail.com>
Date: Thu,  4 Jun 2015 20:11:00 +0530

> According to <stdbool.h> false is always '0' and
> Static variables are initialised to 0 by GCC.
> 
> Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>

Applied, thanks.
