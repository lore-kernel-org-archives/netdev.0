From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 11:35:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409021135.57632.margitsw@t-online.de>
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
> it shouldn't hinder 2.6 in it's progression.
I consider this a regression.
As schedule_timeout is used elesewhere in the prism54 code,
we are using a consistent and documented method.

Margit
