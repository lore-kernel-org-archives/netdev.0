From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: rds: chnaging the return type from int to void
Date: Fri, 30 Oct 2015 17:01:22 +0300
Message-ID: <56337832.1020904@cogentembedded.com>
References: <saurabh.truth@gmail.com>
 <1446185985-6128-1-git-send-email-saurabh.truth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Saurabh Sengar <saurabh.truth@gmail.com>, chien.yen@oracle.com,
	davem@davemloft.net, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446185985-6128-1-git-send-email-saurabh.truth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/30/2015 9:19 AM, Saurabh Sengar wrote:

> as return type

    Result.

> of function rds_iw_flush_mr_pool no where checked,

    Nowhere.

> chnaging its return type from int to void.

    s/chnaging/changing/ both here and in the subject.

> also removing the unused variable rc as there is nothing to return.
>
> Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>

[...]

MBR, Sergei
