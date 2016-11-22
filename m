From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: linux-next: build warnings after merge of the net-next tree
Date: Mon, 21 Nov 2016 17:28:39 -0800
Message-ID: <e5c5a4d7-355e-b8a6-9526-d6acbe4e54f8@gmail.com>
References: <20161122122216.575b1793@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20161122122216.575b1793@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+Thomas, Gregory,

On 11/21/2016 05:22 PM, Stephen Rothwell wrote:
[snip]
> 
> Introduced by commit
> 
>   a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")
> 
> "a few warnings" is a matter of perception.  :-(

Thomas, based on our IRC conversation, do you already have patches for
mvneta and mvpp2 to build without warning on 64-bit or should I prepare
patches for these?
-- 
Florian
