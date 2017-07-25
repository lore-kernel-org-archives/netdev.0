From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: Re: [PATCH 00/13] net: dsa: lan9303: unicast offload, fdb,mdb,STP
Date: Tue, 25 Jul 2017 09:34:15 +0200
Message-ID: <75675e48-c7d7-794b-f610-7b775cc9bf50@zenitel.com>
References: <525d9bb74bfa42c1b7a54930e14cf5ea@nooslMX1.zenitelcss.com>
 <db9b265a-ed4a-c6f7-8959-21c9314a6ec0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <corbet@lwn.net>,
        <andrew@lunn.ch>, <vivien.didelot@savoirfairelinux.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <db9b265a-ed4a-c6f7-8959-21c9314a6ec0@gmail.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24. juli 2017 18:54, Florian Fainelli wrote:
> 
> First thing would be to get your patch submissions square, because the
> patches do not appear to have been sent as a reply to this cover letter,
> and worse yet, they are all appearing with their commit date, which is
> highly confusing since that makes them go back in time for some of them.
> 

Hi all!

I am very sorry for the email-thread mess. Once the emails showed up on 
the spinics mirror I realized I had made a fool of my self. I see now 
that I have to add --thread to "git format-patch", when _not_ using 
"git send-email" as the backend. (I did not get "git send-email" to work
with the company email server.)

I had noted that "git format-patch" preserved commit dates, but I
wrongly thought that was "a feature, not a bug". From now on I will
make sure to "git rebase --ignore-date master".

Egil

DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
