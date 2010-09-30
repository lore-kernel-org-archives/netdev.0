From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: how to use secure_tcp_sequence_number
Date: Thu, 30 Sep 2010 19:01:25 +0200
Message-ID: <AANLkTikWop213k7cBXAaoCMw_8LouX-qauYEbHD=d1Vh@mail.gmail.com>
References: <AANLkTimA6jJbCvtxFi41JbH_XSJtKo0FrDE=fQ2OiafY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimA6jJbCvtxFi41JbH_XSJtKo0FrDE=fQ2OiafY@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If i attempt to insert the module that uses the
secure_tcp_sequence_number i get this error message:

from insmod:  -1 Invalid module format
and from dmesg: version magic '2.6.35.4 SMP mod_unload 586 ' should be
'2.6.35.4 SMP mod_unload modversions 586 '

what's the matter?

On Wed, Sep 29, 2010 at 6:46 PM, Nicola Padovano
<nicola.padovano@gmail.com> wrote:
> Hi all. How can I export the secure_tcp_sequence_number to use it in my modules?
>
> --
> Nicola Padovano
> e-mail: nicola.padovano@gmail.com
> web: http://npadovano.altervista.org
>
> "My only ambition is not be anything at all; it seems the most
> sensible thing" (C. Bukowski)
>



-- 
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
