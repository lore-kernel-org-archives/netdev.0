From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 12:12:53 +0200
Message-ID: <48870425.50908@trash.net>
References: <bug-11144-10286@http.bugzilla.kernel.org/>	<20080722034850.dbbc5566.akpm@linux-foundation.org>	<4886E49D.6010700@tvcablenet.be> <20080723010522.389a948f.akpm@linux-foundation.org> <4886F727.6010301@tvcablenet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-15?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4886F727.6010301-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46ran=E7ois Valenduc wrote:
> OK, thanks for the explanation. But do you have more ideas about the=20
> problem ?

I tested myself using dhcpcd 3.2.3 on an ethernet device and it
works fine, so this appears to be driver related.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
