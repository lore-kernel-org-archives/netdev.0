From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] Net: kconfig, correct traffic shaper
Date: Sun, 05 Nov 2006 15:34:56 +0100
Message-ID: <454DF690.2010405@trash.net>
References: <453BA26D.9010504@trash.net>, <43123154321532@wsc.cz> <1202725131414221392@wsc.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Alan Cox <alan@redhat.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965882AbWKEOfE@vger.kernel.org>
To: Jiri Slaby <jirislaby@gmail.com>
In-Reply-To: <1202725131414221392@wsc.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> Ok, thanks for comments. Here it comes, please (n)ack it:
> 
> --
> 
> kconfig, correct traffic shaper
> 
> As Patrick McHardy <kaber@trash.net> suggested, Traffic Shaper is
> now obsolete and alternative to it is no longer CBQ, since its problems with
> virtual devices, alter Kconfig text to reflect this -- put a link to the
> traffic schedulers as a whole.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Alan Cox <alan@redhat.com>
> Cc: Patrick McHardy <kaber@trash.net>

Looks good, thanks.
