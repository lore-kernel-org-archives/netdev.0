From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Signed-off-by missing for commit in the net-next
 tree
Date: Thu, 31 Aug 2017 03:38:49 +1000
Message-ID: <20170831033849.6a458de5@canb.auug.org.au>
References: <20170831025131.56d2cf92@canb.auug.org.au>
        <32dc9201-c7a2-2cf0-e8a1-1c735b8784ee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <32dc9201-c7a2-2cf0-e8a1-1c735b8784ee@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, 30 Aug 2017 10:53:48 -0600 David Ahern <dsahern@gmail.com> wrote:
>
> On 8/30/17 10:51 AM, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Commit
> > 
> >   1b70d792cf67 ("ipv6: Use rt6i_idev index for echo replies to a local address")
> > 
> > is missing a Signed-off-by from its author.
> 
> Eric pointed this out last night. The commit message copied output from
> a command that contained '---' so git ignored the remainder of the message.

Rats!

-- 
Cheers,
Stephen Rothwell
