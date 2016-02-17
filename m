From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: Re: [PATCH] lance: Return correct error code
Date: Wed, 17 Feb 2016 19:54:05 +0530
Message-ID: <CA+5yK5H1wc4qJ2mr511M2e05SQDpfeZhbTvsbLT+C+2nt1=2JA@mail.gmail.com>
References: <20160217133516.GA31497@amitoj-Inspiron-3542>
	<56C480B5.7000902@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C480B5.7000902@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 17, 2016 at 7:46 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 2/17/2016 4:35 PM, Amitoj Kaur Chawla wrote:
>
>> The return value of kzalloc on failure should be -ENOMEM and
>
>
>    kzalloc() returns NULL on failure! You need to clarify your patch
> description, so that it makes some sense.
>

Okay, thanks for the feedback. Will send v2.

Amitoj
