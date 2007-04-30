From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Mon, 30 Apr 2007 10:16:37 -0700
Message-ID: <46362475.3080605@hp.com>
References: <4632894D.40705@hp.com>	<20070427.163934.106263903.davem@davemloft.net>	<46328BB0.9030501@hp.com>
	<20070427.165232.74560572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lawver1@llnl.gov, netdev@vger.kernel.org, mst@dev.mellanox.co.il,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070427.165232.74560572.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 27 Apr 2007 16:48:00 -0700
> 
> 
>>No problem - just to play whatif/devil's advocate for a bit
>>though... is there any way to tie that in with the setting of
>>net.ipv4.ip_forward (and/or its IPv6 counterpart)?
> 
> 
> Even ignoring that, consider the potential issues this
> kind of problem could be causing netfilter.


OK, I'll show my ignorance and bite - what sort of issues with 
netfilter?  Is it tied to link-local MTUs?

rick jones
