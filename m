From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: BUG: dst underflow (again)
Date: Fri, 05 Nov 2004 07:42:50 -0200
Message-ID: <418B4B1A.8@conectiva.com.br>
References: <4178AB0D.6060107@pobox.com> <20041022.155159.98771450.yoshfuji@linux-ipv6.org> <20041022075947.GA15795@xi.wantstofly.org> <1099577717.1039.155.camel@jzny.localdomain> <20041104221801.584c8f11.davem@davemloft.net> <20041105091427.GB28112@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        yoshfuji@linux-ipv6.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041105091427.GB28112@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Lennert Buytenhek wrote:
> On Thu, Nov 04, 2004 at 10:18:01PM -0800, David S. Miller wrote:
> 
> 
>>BTW Lennert, the decoded addresses are extremely helpful. Thanks.
> 
> 
> I'm glad.
> 
> 
> 
>>But let me ask, do you have any IPSEC policies in the kernel
>>when these BUGs trigger?  If so, I'm pretty sure I know what
>>the problem may be.
> 
> 
> IPSEC.. not that I know of.  So unless my distro does stuff behind
> my back, no.  How do I make sure?

setkey -DP
