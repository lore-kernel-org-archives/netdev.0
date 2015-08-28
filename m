From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openswitch: fix typo CONFIG_NF_CONNTRACK_LABEL
Date: Fri, 28 Aug 2015 13:40:20 -0700 (PDT)
Message-ID: <20150828.134020.1906259838454588931.davem@davemloft.net>
References: <1440751196-25787-1-git-send-email-valentinrothberg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org
To: valentinrothberg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440751196-25787-1-git-send-email-valentinrothberg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentin Rothberg <valentinrothberg@gmail.com>
Date: Fri, 28 Aug 2015 10:39:56 +0200

> Fix typo in conntrack.c
> s/CONFIG_NF_CONNTRACK_LABEL/CONFIG_NF_CONNTRACK_LABELS/
> 
> Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
> ---
> The typo was added by commmit c2ac66735870 ("openvswitch: Allow matching
> on conntrack label").
> I detected the issue scripts/checkkconfigsymbols.py

Applied, thank you.
