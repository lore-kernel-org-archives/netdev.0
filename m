From: Bernard F6BVP <f6bvp@free.fr>
Subject: Re: [AX25] inconsistent lock state
Date: Fri, 01 Jul 2011 15:00:35 +0200
Message-ID: <4E0DC4F3.6010203@free.fr>
References: <4B2CD772.1030106@upmc.fr> <201106171536.15660.arnd@arndb.de> <20110617135147.GA3470@linux-mips.org> <201106171611.10655.arnd@arndb.de> <4E06040B.7040309@free.fr> <20110625163942.GB20976@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20110625163942.GB20976@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Now, who is going to commit this mkiss patch and the equivalent one for=
=20
sixpack.c ?

Bernard, f6bvp


Le 25/06/2011 18:39, Ralf Baechle DL5RB a =E9crit :
> On Sat, Jun 25, 2011 at 05:51:39PM +0200, f6bvp wrote:
>
>> I applied the patch and since then I could not reproduce the
>> inconsistent lock state.
>> Thus mkiss patch fixed it.
>
> I also think the patch is the right thing, so
>
> Acked-by: Ralf Baechle<ralf@linux-mips.org>
>
>    Ralf
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
