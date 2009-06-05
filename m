From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/5] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Fri, 5 Jun 2009 14:45:06 +0400
Message-ID: <bc64b4640906050345t5ed23d7bxc8a777a4a0ada147@mail.gmail.com>
References: <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
	 <1244184737.22576.94.camel@johannes.local>
	 <20090605071529.GA7064@doriath.ww600.siemens.net>
	 <20090605.005418.07362083.davem@davemloft.net>
	 <20090605091229.GA25280@doriath.ww600.siemens.net>
	 <20090605094619.GB23085@build.ossfans.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090605094619.GB23085-RnUUNP8nt3rKl/7hFL4KYti2O/JbrIOy@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/5 Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>:
>> @@ -0,0 +1,523 @@
>> +/*
>> + * Netlink inteface for IEEE 802.15.4 stack
>> + *
>> + * Copyright 2007, 2008 Siemens AG
>> + *
>> + * This program is free software; you can redistribute it and/or mo=
dify
>> + * it under the terms of the GNU General Public License version 2
>> + * as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e along
>> + * with this program; if not, write to the Free Software Foundation=
, Inc.,
>> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
>> + *
>> + * Written by:
>> + * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
> Dmitry, please toss all my @siemens.com addresses from all patches, s=
ince my
> access is already disabled and it's pointless to have invalid emails
> in source tree. Please replace them with @ossfans.org ones.

Could you please send an incremental patch on top of this serie? I
hope that my last
push can be pulled/merged and I don't want to redo all commits.


--=20
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
