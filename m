From: "Jaswinder Singh" <jaswinderlinux@gmail.com>
Subject: Re: Firmware patches for Network
Date: Sat, 20 Dec 2008 01:41:36 +0530
Message-ID: <3f9a31f40812191211x12fc08cateb3502c6765d0c4c@mail.gmail.com>
References: <3f9a31f40812191131m48802157r596d7773fb435f34@mail.gmail.com>
	 <1229715971.3097.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net,
	"Jeff Garzik" <jeff@garzik.org>,
	"David Woodhouse" <dwmw2@infradead.org>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1229715971.3097.6.camel@achroite>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ben,

On Sat, Dec 20, 2008 at 1:16 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>> 3. git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>
> This one.
>

4 out of 10 Networking's firmware patches are already floating in
linux-next from long time :

1. firmware: convert e100 driver to request_firmware()
http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commit;h=c98e632b660ef49b67a9591040230b518785e38a
2. firmware: convert acenic driver to request_firmware()
http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commit;h=e39c0e190f52331b35931fbe5e34a07114d66171
3. firmware: convert tg3 driver to request_firmware()
http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commit;h=aadd3ed38a6745e21dc8d2f388bbba42ead0a085
4. starfire: use request_firmware()
http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=commit;h=df3eea674103ce451357be8eb873092943ad3551

Should I need to resend all 10 or remaining 6.

Thank you,

Jaswinder Singh.
