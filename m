From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Tue, 14 Feb 2017 09:40:01 -0800
Message-ID: <dffab7ef3a364a49a28d876f577561db@eusanexr01a.eu.qualcomm.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <ath10k@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
To: =?utf-8?q?Amadeusz_S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:17984 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932121AbdBNRkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:40:13 -0500
In-Reply-To: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amadeusz Sławiński wrote:
> it adds unnecessary level of indirection, while we just access structure
> field
> 
> Signed-off-by: Amadeusz Sławiński <amadeusz.slawinski@tieto.com>

3 patches applied to ath-next branch of ath.git, thanks.

56ac13bfc703 ath10k: remove ath10k_vif_to_arvif()
182f1e5a626e ath10k: use size_t for len variables
6d2191135637 ath10k: fix comment

-- 
https://patchwork.kernel.org/patch/9551559/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
