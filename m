From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: refcount_t + (resend to wider audience)
Date: Fri, 28 Jul 2017 19:41:17 +0200
Message-ID: <20170728174117.GL2132@lunn.ch>
References: <cc109bec-d4bb-8965-3169-fe36d85e6e19@android.com>
 <adaee9d9-1d35-921c-36b3-e32e6c8ce9e3@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, stable@vger.kernel.org
To: Mark Salyzyn <salyzyn@android.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <adaee9d9-1d35-921c-36b3-e32e6c8ce9e3@android.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 10:15:23AM -0700, Mark Salyzyn wrote:
> (Resend to wider audience to comply with
> Documentation/networking/netdev-FAQ.txt)
> 
> Please apply/backport the following upstream feature and followup
> grouped fixes patches to the stable trees (expect included in at least
> 3.10.y, 3.18.y, 4.4.y and 4.9.y):

.. _stable_kernel_rules:

Hi Mark

Everything you ever wanted to know about Linux -stable releases
===============================================================

Rules on what kind of patches are accepted, and which ones are not, into the
"-stable" tree:

 - It must be obviously correct and tested.
 - It cannot be bigger than 100 lines, with context.

The first patch you list is 342 lines. The second one is 634.

Please could you read the rules and then provide some justification
for ignoring many of the rules.

    Andrew
