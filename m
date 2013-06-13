From: Tommi Rantala <tt.rantala@gmail.com>
Subject: =?windows-1252?Q?Re=3A_include=2Fnet=2Fipv6=2Eh=3A408=3A38=3A_warning=3A_=91=2A=28=28void_=2A?=
	=?windows-1252?Q?=29=26addr=2B8=29=92_may_be_used_uninitialized_in_this_function?=
Date: Thu, 13 Jun 2013 20:20:28 +0300
Message-ID: <CA+ydwtoF7SEf20h+qXxFi4hAH4J0Z+6O_Zx5XSQ4xthn7daJpw@mail.gmail.com>
References: <CA+ydwtrVHDE65dVTBijGguZDK0+=+tzi+nn1UywRqfn9Rx4ZuA@mail.gmail.com>
	<1371137986.3252.112.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371137986.3252.112.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/6/13 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2013-06-13 at 18:16 +0300, Tommi Rantala wrote:
>> Hello, I'm seeing the following compiler warnings. Do these make any
>> sense? I'm doing a x86-64 build.
>
>> $ gcc --version
>> gcc (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3
>> Copyright (C) 2012 Free Software Foundation, Inc.
>> This is free software; see the source for copying conditions.  There is NO
>> warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
>>
>> config:
>> http://fpaste.org/18443/13711363/
>
> Well, what tree are you using ?

mainline, the warnings are from v3.10-rc5-0-g317ddd2.

They are not new, also visible e.g. in v3.9-0-gc1be5a5.
