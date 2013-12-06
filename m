From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4] sctp: check the rto_min and rto_max
Date: Fri, 06 Dec 2013 09:54:53 +0100
Message-ID: <52A190DD.7070700@redhat.com>
References: <529FE2AD.5020700@huawei.com> <20131205133217.GA20349@hmsreliant.think-freely.org> <52A088A9.9090200@gmail.com> <52A0A8ED.70903@redhat.com> <52A12727.1060308@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wang Weidong <weidong1991.wang@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756937Ab3LFIzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:55:04 -0500
In-Reply-To: <52A12727.1060308@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 02:23 AM, Wang Weidong wrote:

> Hm, I do it for according to the proc_sctp_do_hmac_alg which is in the same file.
> If I fix this, I think it is better to fix the proc_sctp_do_hmac_alg as well.
> Should I do it a patch or another patch?

Sure, feel free.
