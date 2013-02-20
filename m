From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Wed, 20 Feb 2013 01:15:57 -0600
Message-ID: <5124782D.3050803@lwfinger.net>
References: <20130219.005206.397289032011003833.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com> <5123BCFF.5090408@lwfinger.net> <20130219.131553.787630407148880340.davem@davemloft.net> <5123C43D.2020602@lwfinger.net> <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com> <512437FA.2030105@lwfinger.net> <CA+XFjipJHGTvzUx6yy1DTc74kbrPEQxM08zW=N1uf43=Q6pwdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Calaby <julian.calaby@gmail.com>,
	David Miller <davem@davemloft.net>, David.Laight@aculab.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, bittorf@bluebottle.com,
	stable@vger.kernel.org
To: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CA+XFjipJHGTvzUx6yy1DTc74kbrPEQxM08zW=N1uf43=Q6pwdg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2013 12:26 AM, G=E1bor Stefanik wrote:
>
> Is this an issue that vendor drivers are also vulnerable to? If it is
> a firmware issue, I would certainly think so.

I also think so, at least if they are using the firmware version that B=
astian is=20
using. His logs don't have that info in them, but I certainly saw the p=
roblem on=20
my BCM4312 using firmware 508.154 from 2009.

Larry
