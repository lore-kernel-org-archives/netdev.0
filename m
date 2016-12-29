From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Namespaceify tcp_max_syn_backlog knob
Date: Thu, 29 Dec 2016 11:39:25 -0500 (EST)
Message-ID: <20161229.113925.64077621856996772.davem@davemloft.net>
References: <1482918753-1235-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1482918753-1235-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kernel@kyup.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482918753-1235-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 28 Dec 2016 17:52:33 +0800

> Different namespace application might require different maximal
> number of remembered connection requests.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
