From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: include/net/ipv6.h:408:38: warning:
 =?UTF-8?Q?=E2=80=98*=28=28void?= =?UTF-8?Q?_*=29&addr+8=29=E2=80=99?= may
 be used uninitialized in this function
Date: Thu, 13 Jun 2013 08:39:46 -0700
Message-ID: <1371137986.3252.112.camel@edumazet-glaptop>
References: <CA+ydwtrVHDE65dVTBijGguZDK0+=+tzi+nn1UywRqfn9Rx4ZuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Tommi Rantala <tt.rantala@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ydwtrVHDE65dVTBijGguZDK0+=+tzi+nn1UywRqfn9Rx4ZuA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-13 at 18:16 +0300, Tommi Rantala wrote:
> Hello, I'm seeing the following compiler warnings. Do these make any
> sense? I'm doing a x86-64 build.

> $ gcc --version
> gcc (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3
> Copyright (C) 2012 Free Software Foundation, Inc.
> This is free software; see the source for copying conditions.  There is NO
> warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> 
> config:
> http://fpaste.org/18443/13711363/

Well, what tree are you using ?
