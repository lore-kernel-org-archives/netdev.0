From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/21] ipv4: ip_output: remove inline marking of
 EXPORT_SYMBOL functions
Date: Sat, 11 May 2013 16:13:12 -0700 (PDT)
Message-ID: <20130511.161312.2021294984526564526.davem@davemloft.net>
References: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
	<1368091192-10245-6-git-send-email-yefremov.denis@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org,
	ldv-project@linuxtesting.org
To: yefremov.denis@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368091192-10245-6-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Efremov <yefremov.denis@gmail.com>
Date: Thu,  9 May 2013 13:19:42 +0400

> EXPORT_SYMBOL and inline directives are contradictory to each other.
> The patch fixes this inconsistency.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>

Applied, thanks.
