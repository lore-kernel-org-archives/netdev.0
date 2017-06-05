From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/dec: Make __de_get_link_ksettings return void
Date: Mon, 05 Jun 2017 11:01:21 -0400 (EDT)
Message-ID: <20170605.110121.1149404417057503000.davem@davemloft.net>
References: <20170604170851.3808-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, tklauser@distanz.ch, tremyfr@gmail.com,
        netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: yuval.shaia@oracle.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20170604170851.3808-1-yuval.shaia@oracle.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Shaia <yuval.shaia@oracle.com>
Date: Sun,  4 Jun 2017 20:08:51 +0300

> Make return value void since function never return meaningfull value
> 
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>

Applied to net-next.
