From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Fri, 19 Nov 2004 15:27:02 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0411191509310.12341@filer.marasystems.com>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
 <20041118190257.GA7084@calma.pair.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "Chad N. Tindel" <chad@tindel.net>
In-Reply-To: <20041118190257.GA7084@calma.pair.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Chad N. Tindel wrote:

> However, the problem still happens.  We see many instances of the kernel
> reporting the wrong user id.

Have you aquired the proper read lock on the tcp connection hash?

Regards
Henrik
