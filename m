From: David Ahern <dsahern@gmail.com>
Subject: Re: linux-next: Signed-off-by missing for commit in the net-next tree
Date: Wed, 30 Aug 2017 10:53:48 -0600
Message-ID: <32dc9201-c7a2-2cf0-e8a1-1c735b8784ee@gmail.com>
References: <20170831025131.56d2cf92@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831025131.56d2cf92@canb.auug.org.au>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/30/17 10:51 AM, Stephen Rothwell wrote:
> Hi all,
> 
> Commit
> 
>   1b70d792cf67 ("ipv6: Use rt6i_idev index for echo replies to a local address")
> 
> is missing a Signed-off-by from its author.
> 

Eric pointed this out last night. The commit message copied output from
a command that contained '---' so git ignored the remainder of the message.
