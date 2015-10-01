From: Ian Morris <ipm@chirality.org.uk>
Subject: Re: [PATCH nf-next] netfilter: Line layout whitespace fixes
Date: Fri, 2 Oct 2015 00:44:03 +0100
Message-ID: <560DC543.3060809@chirality.org.uk>
References: <1443089406-8996-1-git-send-email-ipm@chirality.org.uk>
 <20150930221707.GA14994@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150930221707.GA14994@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 30/09/15 23:17, Pablo Neira Ayuso wrote:
> On Thu, Sep 24, 2015 at 11:10:06AM +0100, Ian Morris wrote:
>> Fixes various whitespace issues detected by checkpatch (e.g. adding spaces between operations, replacing spaces with tabs, etc)
>>
>> No changes detected by objdiff.
> These large cleanup patch causes problems for -stable maintainers,
> since they have more conflicts when backporting stuff.
>
> I'd rather keep this back.
>
Please help me understand: until when do you propose such changes be 
deferred? Or are you suggesting we should apply changes more 
incrementally somehow?
