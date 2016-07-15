From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [net-next 5/6] libcxgb: export ppm release and tagmask set api
Date: Fri, 15 Jul 2016 09:15:50 -0500
Message-ID: <09c901d1dea3$63d1e2b0$2b75a810$@opengridcomputing.com>
References: <cover.1467998292.git.varun@chelsio.com> <d3d6ff733cfba2fa6caf6d4a42887adc60345ea7.1467998293.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<target-devel@vger.kernel.org>, <nab@linux-iscsi.org>,
	<gerlitz.or@gmail.com>, <james.bottomley@hansenpartnership.com>,
	<indranil@chelsio.com>
To: "'Varun Prakash'" <varun@chelsio.com>, <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <d3d6ff733cfba2fa6caf6d4a42887adc60345ea7.1467998293.git.varun@chelsio.com>
Content-Language: en-us
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Export cxgbi_ppm_release() to release
> ppod manager and cxgbi_tagmask_set() to
> set tag mask, they are used by cxgb3i, cxgb4i
> and cxgbit.
> 
> Signed-off-by: Varun Prakash <varun@chelsio.com>

Looks good.

Reviewd-by: Steve Wise <swise@opengridcomputing.com>
