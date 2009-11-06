From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]atl1c:change atl1c_buffer struct and
 restructure clean atl1c_buffer procedure
Date: Fri, 06 Nov 2009 00:32:15 -0800 (PST)
Message-ID: <20091106.003215.189008196.davem@davemloft.net>
References: <12574319533672-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754948AbZKFIbv@vger.kernel.org>
In-Reply-To: <12574319533672-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Thu, 5 Nov 2009 22:39:13 +0800

> change atl1c_buffer struct, use "u16 flags" instead of "u16 state"
> to store more infomation for atl1c_buffer, and restructure clean
> atl1c_buffer procedure, add common api atl1c_clean_buffer.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

Applied, thanks.
