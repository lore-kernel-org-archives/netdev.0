From: Tom Gundersen <teg@jklm.no>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Sat, 14 Jan 2012 20:26:01 +0100
Message-ID: <CAG-2HqXfYXMZiG8LmR9iopjfHVwkCJcORbQ3vSpn3uYQ22ohLQ@mail.gmail.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
 <4F11CD4C.9020308@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kay Sievers <kay.sievers@vrfy.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Andy Whitcroft <apw@canonical.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49663 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab2ANT0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 14:26:24 -0500
In-Reply-To: <4F11CD4C.9020308@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Larry,

On Sat, Jan 14, 2012 at 7:45 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Thanks for the heads-up. Do you have a reference for the problem with
> rtlwifi/rtl8192sefw.bin? Google did not find anything that looked
> appropriate.

I believe the logs attached to this bug comment deal with rtlwifi:
<https://bugs.archlinux.org/task/27938#comment87952>.

Cheers,

Tom
