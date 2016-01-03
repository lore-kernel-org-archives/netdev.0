From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: net-libertas: Better exception handling in if_spi_host_to_card_worker()
Date: Sun, 3 Jan 2016 16:18:11 +0100
Message-ID: <CACna6rzoJLRuTTDi3JjXg1roDbk3HXcBhhe0iOUH9xRaGU5p7A@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<5686F0B2.5000000@users.sourceforge.net>
	<56870866.7020000@cogentembedded.com>
	<568785B3.5000905@users.sourceforge.net>
	<alpine.DEB.2.02.1601020914100.2063@localhost6.localdomain6>
	<5687939E.7010701@users.sourceforge.net>
	<5687A2C7.3000704@gmail.com>
	<5687B2BC.8090901@users.sourceforge.net>
	<5688EBAC.5000701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend van Spriel <aspriel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5688EBAC.5000701-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3 January 2016 at 10:36, Arend van Spriel <aspriel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 02-01-16 12:21, SF Markus Elfring wrote:
>>> Did you look at the resulting assembly code for different target ar=
chitectures?
>>
>> Not yet. - Which execution system variants would you recommend for
>> further comparisons?
>
> Guess x86{,_64} and arm would be good candidates, ie. CISC vs. RISC.

Oh, don't forget about MIPS with its fancy branches handling. You know
about it, don't you?

I'm against this patch as well.

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
