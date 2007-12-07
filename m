From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/20] net/ipv4/cipso_ipv4.c: use LIST_HEAD instead of
 LIST_HEAD_INIT
Date: Fri, 07 Dec 2007 00:49:54 -0800 (PST)
Message-ID: <20071207.004954.81492470.davem@davemloft.net>
References: <1196957076-5706-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754187AbXLGIuO@vger.kernel.org>
In-Reply-To: <1196957076-5706-1-git-send-email-crquan@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng <crquan@gmail.com>
Date: Fri,  7 Dec 2007 00:04:36 +0800

> single list_head variable initialized with LIST_HEAD_INIT could almost
> always can be replaced with LIST_HEAD declaration, this shrinks the code
> and looks better.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Applied.
