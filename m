From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:liquidio: use kmemdup
Date: Fri, 20 May 2016 19:50:45 -0400 (EDT)
Message-ID: <20160520.195045.1454213439154888801.davem@davemloft.net>
References: <1463665972-16451-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: falakreyaz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463665972-16451-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Thu, 19 May 2016 19:22:49 +0530

> Use kmemdup when some other buffer is immediately copied into allocated
> region. It replaces call to allocation followed by memcpy, by a single
> call to kmemdup.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>

Applied.
