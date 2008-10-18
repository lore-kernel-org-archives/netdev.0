From: "Alexander Beregalov" <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.27-05178-g2e532d6: list_add corruption
Date: Sat, 18 Oct 2008 19:50:17 +0400
Message-ID: <a4423d670810180850w1e3845a5lf4dae12c0a001e3d@mail.gmail.com>
References: <a4423d670810171220t4d5602fekcb66e18758149925@mail.gmail.com>
	 <Pine.LNX.4.64.0810171617490.21410@alien.or.mcafeemobile.com>
	 <a4423d670810172341y5ae5542jea66ead938ba652d@mail.gmail.com>
	 <Pine.LNX.4.64.0810180737100.21525@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kernel Testers List" <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Davide Libenzi" <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0810180737100.21525-GPJ85BhbkB8RepQJljzAVbITYcZ0+W3JAL8bYrjMMd8@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2008/10/18 Davide Libenzi <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>:
> On Sat, 18 Oct 2008, Alexander Beregalov wrote:
>
>> > This is very likely to be caused by a patch that went in a few days ago.
>> > Already posted a fix to Andrew.
>> >
>>
>> Is it the same problem? 2.6.27-05577-g0cfd810
>
> Hard to be sure, but certainly a double insert can create a similar
> problem. The only way to tell is to get the fix and retry.
I have already applied your patch and the kernel works better, no
errors anymore.
Thanks
