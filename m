From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/4] ipv4: Namespaceify tcp_fastopen knob
Date: Thu, 28 Sep 2017 10:47:43 -0700 (PDT)
Message-ID: <20170928.104743.328188042099346336.davem@davemloft.net>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 27 Sep 2017 11:35:40 +0800

> Different namespace application might require enable TCP Fast Open
> feature independently of the host.
> 
> This patch series continues making more of the TCP Fast Open related
> sysctl knobs be per net-namespace.
> 
> Reported-by: Luca BRUNO <lucab@debian.org>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
