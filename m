From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: qmi_wwan: fix Cinterion PLXX product ID
Date: Mon, 30 Sep 2013 15:04:34 -0400 (EDT)
Message-ID: <20130930.150434.227366361448728622.davem@davemloft.net>
References: <1380121356-28601-1-git-send-email-aleksander@lanedo.com>
	<376FB829F3ECB542B825EAF4D8CA8A9701F9D6114530@CROEXCFWP03.gemalto.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Hans-Christoph.Schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org, Nicolaus.Colberg-av01+Y74gORBDgjK7y7TUQ@public.gmane.org
To: Christian.Schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <376FB829F3ECB542B825EAF4D8CA8A9701F9D6114530-6vtk6ynWDJf9L9UzlSODQOG7l92LEt8e@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Schmiedl Christian <Christian.Schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 26 Sep 2013 16:02:13 +0200

> Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org> writes:
> 
>> Cinterion PLXX LTE devices have a 0x0060 product ID, not 0x12d1.
>>
>> The blacklisting in the serial/option driver does actually use the
>> correct PID, as per commit 8ff10bdb14a52e3f25d4ce09e0582a8684c1a6db
>> ('USB: Blacklisted Cinterion's PLxx WWAN Interface').
> 
> Thanks for patching
> 
> Acked-by: Christian Schmiedl <christian.schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>

Applied, thanks everyone.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
