From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Wed, 12 Nov 2014 14:49:01 +0100
Message-ID: <CA+icZUUAigR9OQrQUOqxqCo4a2_5zkoU6uAy0eQCxQ_ZTeOBow@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
	<CAAP7ucKO2D8B1gG943aNcqWuLm2UWt3AsfZAh5bzeaA1gzSaHQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>, Greg KH <greg@kroah.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:54804 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbaKLNtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 08:49:03 -0500
In-Reply-To: <CAAP7ucKO2D8B1gG943aNcqWuLm2UWt3AsfZAh5bzeaA1gzSaHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 12:51 PM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
>
[...}
> I saw the reporter talk about Ubuntu Precise (12.04) and Trusty (14.04), so
> only in the latter mmcli will be available (if I'm not mistaken). For
> Precise, this Ubuntu page shows how to enable debug logs:
> https://wiki.ubuntu.com/DebuggingModemmanager
>

That wiki needs to be pimped-up (-> clarify on testing tools aka
outdated "mm-test.py", -> Ubuntu releases w/ and w/o upstart, etc.).

- Sedat -

"test: remove testers of the old interface"
[1] http://cgit.freedesktop.org/ModemManager/ModemManager/commit/?id=f3f499fcec13e6ffa9a428972c1108e7c23065d2
