From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Sun, 14 Sep 2003 14:08:28 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
References: <20030912204947.5267e3aa.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hadi@cyberus.ca, greearb@candelatech.com, jgarzik@pobox.com,
   scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030912204947.5267e3aa.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org






David Miller wrote:

>Back to the main topic, maybe we should set dev->tx_queue_len to
>1000 by default for all ethernet devices.


I definately agree with setting the dev->tx_queue_len to 1000 as a default
for all ethernet adapters. All adapters will benefit from this change.


regards,

----------------------------------------------------------------------------------

***  ALWAYS THINK POSITIVE ***
