From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: can: Use common error handling code in vxcan_newlink()
Date: Sat, 28 Oct 2017 22:13:32 +0200
Message-ID: <8761e059-d33c-a157-4b2f-f01dbdf2a91e@users.sourceforge.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
 <5a76bb36-4ae0-eca2-ae34-69c2bfddb634@users.sourceforge.net>
 <4d612668-5423-4ce3-a4f5-ee394d7ddd21@hartkopp.net>
 <19ca5f23-fbb0-aaae-bff5-d634af66c264@users.sourceforge.net>
 <9d9b724b-229a-acab-54f8-6c45dda96f44@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <9d9b724b-229a-acab-54f8-6c45dda96f44@hartkopp.net>
Content-Language: en-GB
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Are you interested in related adjustments for a bigger code base?
> 
> No. Definitely not.

You might have noticed that I am proposing similar changes already
for other software modules.   ;-)


> If you aim for the the deletion of “ < 0” for all rtnl_configure_link() users
> you would need to do this consistently.

How do you see the software situation around a function
like “register_netdevice”?

Regards,
Markus
