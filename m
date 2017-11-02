From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [v2] can: Use common error handling code in vxcan_newlink()
Date: Thu, 2 Nov 2017 09:22:08 +0100
Message-ID: <205ba2b1-ae1d-d0ae-7d78-47d2285ed3fc@hartkopp.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
 <23fbbdba-fb11-a6bc-7d6a-4af43ef79503@users.sourceforge.net>
 <08fd31d5-8677-81e7-65d6-40d501017db6@hartkopp.net>
 <2346609d-85f6-6eec-e492-d15ba1b6489a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        linux-can@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2346609d-85f6-6eec-e492-d15ba1b6489a@users.sourceforge.net>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2017 08:37 PM, SF Markus Elfring wrote:

> These addresses were suggested (or recommended?) by the script “get_maintainer.pl”.

I know.

(..)

> How does this view fit to the information in the section “5) Select
> the recipients for your patch” from the document “submitting-patches.rst”?

We discussed and agreed about your patch. It is clear and simple and has 
no side effects to any other driver nor other subsystems.

It was just about getting *this* patch into upstream where the Linux CAN 
ML is the right place to post - that was my suggestion. So there was no 
need to take the *standard* get_maintainer mail pump-gun again for this 
patch in order to save bandwidth, energy and peoples lifetime :-)

Regards,
Oliver
