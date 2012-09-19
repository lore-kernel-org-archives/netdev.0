From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] Added information about which firmware file is being requested.
Date: Wed, 19 Sep 2012 22:39:56 +1000
Message-ID: <CAGRGNgUGOPt2iRaL+HGxsK-uFjSfmQVW6S0TzWhSgdZv7AJqTw@mail.gmail.com>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	=?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348053493-22955-1-git-send-email-jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jarl,

You should really mention which driver these are for in the subject line, say:

[PATCH] b43: Added information about which firmware file is being requested

On Wed, Sep 19, 2012 at 9:18 PM, Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org> wrote:
> This is informative information to provide about which actual firmware
> file is being used.

Also, this patch is so small and obvious that you could arguably get
away with something like:

Subject: [PATCH] b43: Log firmware filename

Log the name of the firmware file requested.


Or something along those lines.

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
