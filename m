From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [patch 01/16]  __FUNCTION__ string concatenation
Date: Thu, 2 Sep 2004 13:02:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409021302.22823.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004, Maximilian scribeth:
> drivers/net/wireless/prism65/islpci_mgt.h, as suggested

Woo, we got another project ? (prism65)

> I don't have the hardware to do a run-time check.
> It should not pose any problems though.

Oh, I think we can safely say that, especially as TRACE
is nowhere referenced  ;-)
(And therefore the patch is unnecessary)

Margit
