From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [2.6 patch] net/sched/: possible cleanups
Date: Sat, 18 Dec 2004 02:16:28 -0200
Message-ID: <41C3AF1C.2010103@conectiva.com.br>
References: <20041215012754.GH12937@stusta.de> <41BF9A95.5050902@conectiva.com.br> <20041218010024.GD21288@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041218010024.GD21288@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Tue, Dec 14, 2004 at 11:59:49PM -0200, Arnaldo Carvalho de Melo wrote:
> 
>>Adrian Bunk wrote:
>>
>>>The patch below contans the following possible cleanups:
>>>- make some needlessly global code static
>>>- sch_htb.c: #undef HTB_DEBUG
>>>
>>>
>>>diffstat output:
>>>include/net/act_api.h   |    3 ---
>>
>>Adrian, may I suggest that you post the networking related patches
>>only to netdev?
> 
> 
> Until now I thought it's never a bad idea to Cc linux-kernel on any 
> patches. Is there a specific reason why you consider this being a bad 
> thing (well, bandwith shouldn't be that much of an issue considering how 
> high-volume linux-kernel is...)?

I mentioned that when making the same request to another person one or
two days ago: all the networking hackers I know are subscribed to netdev,
several of them aren't subscribed to linux-kernel.

- Arnaldo
