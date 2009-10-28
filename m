From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next]atl1c: duplicate atl1c_get_tpd
Date: Tue, 27 Oct 2009 22:31:26 -0700 (PDT)
Message-ID: <20091027.223126.239262072.davem@davemloft.net>
References: <12567068551959-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757414AbZJ1FbE@vger.kernel.org>
In-Reply-To: <12567068551959-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Wed, 28 Oct 2009 13:14:15 +0800

> From: Jie Yang <jie.yang@atheros.com>
> 
> remove duplicate atl1c_get_tpd, it may cause hardware to send wrong packets.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

Applied, thanks.
