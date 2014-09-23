From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH] ath: change logging functions to return void
Date: Tue, 23 Sep 2014 17:05:34 +0300
Message-ID: <27145768.oo3Xk8YHvr@lx-wigig-72>
References: <1411407334.2952.46.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	<ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	wil6210 <wil6210@qca.qualcomm.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth01.qualcomm.com ([65.197.215.72]:6608 "EHLO
	sabertooth01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbaIWOFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 10:05:41 -0400
In-Reply-To: <1411407334.2952.46.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, September 22, 2014 10:35:34 AM Joe Perches wrote:
> Other miscellanea:
> 
> o add __printf verification to wil6210 logging functions
>   No format/argument mismatches found
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 

For wil6210:

Acked-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
