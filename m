From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip_route_me_harder -> xfrm_lookup
Date: Thu, 18 Mar 2004 17:31:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059CECA.8080109@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040308115858.75cdddca.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 08 Mar 2004 15:46:37 +0100
> Patrick McHardy <kaber@trash.net> wrote:
>>
>>I have been working on a set of patches for IPsec+Netfilter, the
>>latest set has been posted to netfilter-devel last week. They will
>>go in patch-o-matic for testing soon, but I will post them
>>to netdev later today, so we won't waste time testing patches
>>before Dave is fine with them.
> 
> 
> Regardless, and I look forward to your work, Herbert's patch is
> absolutely correct so I'm going to apply it for now.
> 
> In fact, your work is less likely to be 2.6.4 material I imagine :)
> So best to get Herbert's simpler fix in for now.
> 

Sorry for the late reply. You're right of course, Herbert's patch is
best for now. The following five mails contain what I've currently
got, it's still rough, but I hope you have some suggestions how to
avoid some ugly things.

Best regards
Patrick
