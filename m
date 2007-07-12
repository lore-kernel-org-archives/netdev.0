From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Thu, 12 Jul 2007 11:40:23 -0500
Message-ID: <46965977.7020807@lwfinger.net>
References: <20070710184155.GA6955@bougret.hpl.hp.com> <4693DD18.1010905@lwfinger.net> <1184211018.9446.0.camel@localhost.localdomain> <20070712163440.GA13445@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070712163440.GA13445-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 
> 	Well, I actually like forcing driver to use frequency, because
> that's an absolute physical measure and contains more meaning.

Yes, but it is easier to keep a channel number in your head than a frequency.

Larry
