From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] fix whitespace errors found by checkpatch.pl
Date: Tue, 17 Mar 2015 15:21:12 -0400 (EDT)
Message-ID: <20150317.152112.1902057116873296620.davem@redhat.com>
References: <1426593287-18619-1-git-send-email-kmulvey@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kmulvey@linux.com
To: kevin@kevinmulvey.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426593287-18619-1-git-send-email-kmulvey@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kevin Mulvey <kevin@kevinmulvey.net>
Date: Tue, 17 Mar 2015 07:54:47 -0400

> make checkpatch happier by fixing some whitespace
> in ip6_tunnel.c and ip6_vti.c
> 
> Signed-off-by: Kevin Mulvey <kmulvey@linux.com>

Your Subject line should specify a subsystem prefix, followed by a colon
character, indicating the area of the kernel where you are making
changes.

In this particular case, "ipv6: " would be an appropriate one to use.

Otherwise in the shortlog, it is impossible to determine where a commit
might be making changes.
