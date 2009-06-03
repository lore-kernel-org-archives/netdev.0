From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/6] crc-itu-t: add bit-reversed calculation
Date: Wed, 3 Jun 2009 16:48:08 +0400
Message-ID: <bc64b4640906030548v2825961ck7fb44ded5d32c376@mail.gmail.com>
References: <1244021629-18409-1-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-2-git-send-email-dbaryshkov@gmail.com>
	 <1244033004.21215.4.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>,
	Darren Salt <linux-Ym6Ivm/Ks7B65+NM0QMiFAbYiX8G1TQY9dF7HbQ/qKg@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244033004.21215.4.camel@deadeye>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/3 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>:
> On Wed, 2009-06-03 at 13:33 +0400, Dmitry Eremin-Solenikov wrote:
> [...]
>> +/**
>> + * crc_itu_t_bitreversed - Compute the CRC-ITU-T for the data buffe=
r;
>> + * the buffer content is assumed to be bit-reversed
> [...]
>
> This short description spills onto two lines which is invalid and bre=
aks
> the generation of docs. =A0Sorry to point this out after recommending=
 the
> patch to you.
>
> I've changed the description to "crc_itu_t_bitreversed - Compute the
> CRC-ITU-T for a bit-reversed data buffer" all on one line.

Changing patch here in accordance with your suggestion.

--=20
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
