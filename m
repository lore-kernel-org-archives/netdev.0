From: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Sat, 21 Dec 2013 15:16:45 -0800
Message-ID: <CAN1v_PuttE1z2sLvscdLZLjpKFexGJeJm_1xxT7UatGeuM65Pw@mail.gmail.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
	<20131221210638.GA30102@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "patches-qTEPVZfXA3Y@public.gmane.org" <patches-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131221210638.GA30102-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 21, 2013 at 1:06 PM, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> On Fri, Dec 20, 2013 at 06:57:27PM -0800, Ravi Patel wrote:
>> This patch adds support for APM X-Gene SoC Queue Manager/Traffic Manager.
>>  QMTM is required by APM X-Gene SoC Ethernet, PktDMA (XOR Engine) and
>>  Security Engine subsystems. All subsystems communicate with QMTM using
>>  messages which include information about the work to be performed and
>>  the location of associated data buffers.
>
> As you failed to respond or even acknowledge any of my review comments
> before, I don't understand what you expect me to do with this patch dump
> again.
>
> Remember, kernel development is about trust.  You need me to trust that
> you know what you are doing, and will be able to handle feedback and
> respond to issues that come up over time.  Right now that trust is in
> the negative zone, around "general annoyance" levels.  It's up to you to
> change that or not, just like it is up to me to take your code, or not.
>
> grumble,
>
> greg k-h

Greg,

I apologize for not responding to your comments before sending patch v2
The main intention of sending patch v2 was to remove APM confidential notice,
which was present in the first QMTM patch.
I wanted to send out patch v2 quickly, so that community can start reviewing
 the QMTM code.

I will go through all your comments and respond it.

pardon,

Ravi
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
