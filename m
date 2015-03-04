From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Linux XIA - merge proposal
Date: Wed, 04 Mar 2015 01:01:57 +0100
Message-ID: <54F64B75.3010109@iogearbox.net>
References: <54F5EF6E.9090303@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Michel Machado <michel@digirati.com.br>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F5EF6E.9090303@digirati.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/2015 06:29 PM, Michel Machado wrote:
...
>     We're fine with clearly marking Linux XIA as being under staging as well as helping to define this review process for network stacks.

With regard to staging, the code there is usually horrible and I'm
not sure anyone really looks there, that would mitigate the review
problem to the time when you try to get it out from there, so I'm
not sure it brings anything. ;)

+1 on what Eric said, would have also been nice if you had clearly
described in your mail (w/o buzz words) what it is and what it does.

Are you trying to introduce a new network stack as an alternative
to the current one, e.g. something like FreeBSD's netgraph?
