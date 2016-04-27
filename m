From: =?UTF-8?Q?Florian_Vall=C3=A9e?= <fvallee@eukrea.fr>
Subject: Re: [PATCH] can: m_can: fix bitrate setup on latest silicon
Date: Wed, 27 Apr 2016 18:47:08 +0200
Message-ID: <CADgCO2_O0EAiV3+HZiobSrM6kaV-QjUHKCtcLjWkjXVZcOXHyQ@mail.gmail.com>
References: <1461678379-28257-1-git-send-email-fvallee@eukrea.fr>
	<571FBD5E.9040807@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?B?RXJpYyBCw6luYXJk?= <ebenard@eukrea.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <571FBD5E.9040807@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26 April 2016 at 21:11, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>
> I wonder whether this small change covers the updates made between
> v3.0.1 and v3.1.0.
>

Probably not, I was mainly interested in fixing basic functionality here :)
(ie: with the default settings we can exchange data frames with
another controller)

>
> Your patch looks very good so far. I would appreciate if you could update the other register changes too as I don't have a hardware to test. I can provide the ISO/NON_ISO config for the netlink interface updates then :-)
>

Ok, I'll have another look at the changes. Thank you for the spec
history btw, it seems bosch only keeps the latest one publicly
available.

Regards,

Florian
