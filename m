From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 07/53] tools: Move Makefile.arch from perf/config to tools/scripts
Date: Mon, 11 Jan 2016 21:52:38 +0800
Message-ID: <5693B3A6.6040508@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com> <1452520124-2073-8-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>,
	"Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-8-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/11 21:47, Wang Nan wrote:
> After this patch other directories can use this architecture detector
> without directly including it from perf's directory. Libbpf would
> utilize it to get proper $(ARCH) so it can receive correct uapi include
> directory.
>
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@kernel.org>
> [Add missing srctree definition in tests/make]
Hi Arnaldo, I guess you will be okay provide your SOB so I add it here.
You didn't provide it on your original code.

Thank you.
