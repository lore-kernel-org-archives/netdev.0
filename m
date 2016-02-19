From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: Re: [PATCH] ehea: Drop owner assignment from platform_driver
Date: Fri, 19 Feb 2016 18:37:24 +0530
Message-ID: <CA+5yK5Ej0TJ3cD-uwNoKdr_JQ+3-smrrWeZoorPKRszO_d4U0Q@mail.gmail.com>
References: <20160219112219.GA2366@amitoj-Inspiron-3542>
	<20160219113524.GR4148@siri.cascardo.eti.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Thadeu Lima de Souza Cascardo <cascardo@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160219113524.GR4148@siri.cascardo.eti.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 19, 2016 at 5:05 PM, Thadeu Lima de Souza Cascardo
<cascardo@debian.org> wrote:
> NACK.
>
> ehea does not use platform_driver_register, it uses
> ibmebus_register_driver, which does not set owner.
>
> Cascardo.

Thanks for the feedback. I'll make sure to check for this in the future.

Amitoj
