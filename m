From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: fore200e: Do not drop const qualifier
Date: Thu, 18 Aug 2016 23:50:42 -0700 (PDT)
Message-ID: <20160818.235042.671072416951678843.davem@davemloft.net>
References: <1471442205-11364-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471442205-11364-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Wed, 17 Aug 2016 15:56:45 +0200

> The data member of structure firmware is const and this constness is
> dropped by some cast.
> This patch add some const for keeping the const information.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Applied.
