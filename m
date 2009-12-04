From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: linux-next: manual merge of the sysctl tree with the net tree
Date: Fri, 04 Dec 2009 07:16:35 -0500
Message-ID: <4B18FDA3.5060601@gmail.com>
References: <20091204194301.ca77fe40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091204194301.ca77fe40.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> Hi Eric,
> 
> Today's linux-next merge of the sysctl tree got a conflict in
> net/ipv4/sysctl_net_ipv4.c between commit
> 519855c508b9a17878c0977a3cdefc09b59b30df ("TCPCT part 1c:
> sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS") from the
> net tree and commit f8572d8f2a2ba75408b97dc24ef47c83671795d7 ("sysctl
> net: Remove unused binary sysctl code") from the sysctl tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Hi, I'm not Eric, but it's my TCPCT patch -- is there something more
that I need to do?

Adding a sysctl was my very first query to Linux lists.  I thought
everything was covered in that and subsequent threads.

    Subject: query: adding a sysctl
    Date: Fri, 02 Oct 2009 00:00:05 -0400
