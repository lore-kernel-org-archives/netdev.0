From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Date: Tue, 26 Nov 2013 18:13:47 -0500
Message-ID: <52952B2B.20309@oracle.com>
References: <522B25B5.6000808@oracle.com> <5294F27D.4000108@oracle.com> <20131126230709.GA10948@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131126230709.GA10948@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2013 06:07 PM, Pablo Neira Ayuso wrote:
> On Tue, Nov 26, 2013 at 02:11:57PM -0500, Sasha Levin wrote:
>> >Ping? I still see this warning.
> Did your test include patch 0c3c6c00c6?

Yeah, it reproduces with today's -next tree, which includes that commit.


Thanks,
Sasha

