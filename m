From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [patch] sctp: fix test for end of loop
Date: Tue, 07 Sep 2010 16:46:58 +0800
Message-ID: <4C85FC02.3040804@cn.fujitsu.com>
References: <20100906122344.GA2764@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53270 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab0IGItN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 04:49:13 -0400
In-Reply-To: <20100906122344.GA2764@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote, at 09/06/2010 08:26 PM:
> +	    &new_addr->transports != &new_asoc->peer.transport_addr_list) {

why did you add this check?


-- 
Best Regards
-----
Shan Wei
