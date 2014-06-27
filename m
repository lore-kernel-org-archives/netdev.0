From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Fri, 27 Jun 2014 13:29:27 +0200
Message-ID: <53AD5597.50205@gmail.com>
References: <20140527203010.GA2764@kernel.org> <5385D47A.3070401@gmail.com> <20140528150720.GB2764@kernel.org> <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com> <20140528195004.GD2764@kernel.org> <063D6719AE5E284EB5DD2968C1650D6D1724FB67@AcuExch.aculab.com> <20140529135547.GG2764@kernel.org> <063D6719AE5E284EB5DD2968C1650D6D1724FC78@AcuExch.aculab.com> <20140529141705.GI2764@kernel.org> <CAKgNAkj-MVfeqEeffWKMNok0yO-Rm1kyY+zhXEy-U9NkB+aLow@mail.gmail.com> <20140624202541.GD3456@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?ISO-8859-1?Q?Ondrej_B=EDlka?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140624202541.GD3456-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/24/2014 10:25 PM, Arnaldo Carvalho de Melo wrote:
> Em Mon, Jun 16, 2014 at 11:58:51AM +0200, Michael Kerrisk (man-pages) escreveu:
>> Hi Arnaldo,
>>
>> Things have gone quiet ;-). What's the current state of this patch?
> 
> Yeah, I kept meaning to prod the other people on this thread about what
> they thought about my last messages, patches, etc. :-)
> 
> Can I have acked-by or even tested-by on those? Is it ok?

I just need to go back and test one point that sounds like it might still be 
broken.

Cheers,

Michael




-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
